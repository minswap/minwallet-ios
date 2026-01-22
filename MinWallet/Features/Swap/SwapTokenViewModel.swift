import SwiftUI
import Combine
import Then
import ObjectMapper
import SwiftyJSON


@MainActor
class SwapTokenViewModel: ObservableObject {
    
    //10s call estimate
    private static let TIME_INTERVAL: Int = 10
    
    private let functionalToken: String = "a04ce7a52545e5e33c2867e148898d9e667a69602285f6a1298f9d68"
    private let functionalName: String = "Liqwid Finance"
    private let migrateTokens = [
        (
            old: TokenDefault(
                symbol: "6ac8ef33b510ec004fe11585f7c5a9f0c07f0c23428ab4f29c1d7d10",
                tName: "4d454c44"),
            new: TokenDefault(
                symbol: "a2944573e99d2ed3055b808eaa264f0bf119e01fc6b18863067c63e4",
                tName: "4d454c44")
        )
    ]
    
    @Published
    var tokenPay: WrapTokenSend
    @Published
    var tokenReceive: WrapTokenSend
    @Published
    var isShowInfo: Bool = false
    @Published
    var isShowRouting: Bool = false
    @Published
    var isShowSwapSetting: Bool = false
    @Published
    var isShowSelectReceiveToken: Bool = false
    @Published
    var isShowCustomizedRoute: Bool = false
    
    @Published
    var warningInfo: [WarningInfo] = []
    @Published
    var isExpand: [WarningInfo: Bool] = [:]
    @Published
    var isConvertRate: Bool = false
    @Published
    var swapSetting: SwapTokenSetting = .init()
    @Published
    var isSwapExactIn: Bool = true
    @Published
    var iosTradeEstimate: EstimationResponse?
    @Published
    var isGettingTradeInfo: Bool = true
    @Published
    var errorInfo: ErrorInfo? = nil
    @Published
    var understandingWarning: Bool = false
    
    @Published
    var selectTokenVM: SelectTokenViewModel = .init(screenType: .swapToken, sourceScreenType: .normal)
    @Published
    var isShowSelectToken: Bool = false
    var isSelectTokenPay: Bool = true
    
    let action: PassthroughSubject<Action, Never> = .init()
    private var cancellables: Set<AnyCancellable> = []
    
    var bannerState: BannerState = .init()
    
    private var workItem: DispatchWorkItem?
    private var tradeInfoTask: Task<(), any Error>?
    
    init(tokenReceive: TokenProtocol?) {
        tokenPay = WrapTokenSend(token: TokenManager.shared.tokenAda)
        if let tokenReceive = tokenReceive {
            let tokenWithAmount = TokenManager.shared.yourTokens?.assets.first(where: { $0.uniqueID == tokenReceive.uniqueID }) ?? tokenReceive
            self.tokenReceive = WrapTokenSend(token: tokenWithAmount)
        } else {
            let minTokenDefault = TokenDefault(
                symbol: String(MinWalletConstant.minToken.split(separator: ".").first ?? ""),
                tName: String(MinWalletConstant.minToken.split(separator: ".").last ?? ""),
                decimal: 6)
            let minToken = TokenManager.shared.yourTokens?.assets.first(where: { $0.uniqueID == minTokenDefault.uniqueID })
            self.tokenReceive = WrapTokenSend(token: minToken ?? minTokenDefault)
        }
        
        subscribeCombine()
        action.send(.getTradingInfo)
    }
    
    func subscribeCombine() {
        unsubscribeCombine()
        action
            .sink { [weak self] action in
                guard let self = self else { return }
                Task {
                    do {
                        try await self.handleAction(action)
                    } catch {
                        self.iosTradeEstimate = nil
                        
                        self.bannerState.showBannerError(error.rawError)
                    }
                }
            }
            .store(in: &cancellables)
        $tokenPay
            .map({ $0.amount.doubleValue })
            .removeDuplicates()
            .dropFirst()
            .debounce(for: .milliseconds(400), scheduler: DispatchQueue.main)
            .sink(receiveValue: { [weak self] amount in
                guard let self = self, isSwapExactIn else { return }
                self.action.send(.amountPayChanged(amount: amount))
            })
            .store(in: &cancellables)
        $tokenReceive
            .map({ $0.amount.doubleValue })
            .removeDuplicates()
            .debounce(for: .milliseconds(400), scheduler: DispatchQueue.main)
            .sink(receiveValue: { [weak self] amount in
                guard let self = self, !isSwapExactIn else { return }
                self.action.send(.amountReceiveChanged(amount: amount))
            })
            .store(in: &cancellables)
        TokenManager.shared.reloadBalance.map { _ in Action.reloadBalance }
            .subscribe(action)
            .store(in: &cancellables)
    }
    
    func unsubscribeCombine() {
        cancellables.forEach({ $0.cancel() })
        cancellables = []
        tradeInfoTask?.cancel()
        workItem?.cancel()
    }
    
    private func handleAction(_ action: Action) async throws {
        switch action {
        case .resetSwap:
            isSwapExactIn = true
            tokenPay.amount = ""
            tokenReceive.amount = ""
            isConvertRate = false

        case let .selectToken(token):
            if isSelectTokenPay {
                guard let token = token, token.uniqueID != tokenReceive.uniqueID, token.uniqueID != tokenPay.uniqueID else { return }
                tokenPay = WrapTokenSend(token: token, amount: tokenPay.amount)
            } else {
                guard let token = token, token.uniqueID != tokenPay.uniqueID, token.uniqueID != tokenReceive.uniqueID else { return }
                tokenReceive = WrapTokenSend(token: token, amount: tokenReceive.amount)
            }
            self.action.send(.getTradingInfo)

        case .swapToken:
            let tempToken = tokenPay
            isSwapExactIn = true
            var isForceGetTradingInfo: Bool = false
            
            if tokenPay.amount.doubleValue == 0 {
                isForceGetTradingInfo = true
            }
            
            tokenPay = tokenReceive
            tokenPay.amount = ""
            tokenReceive = tempToken
            tokenReceive.amount = ""
            isConvertRate = false
            
            if isForceGetTradingInfo {
                self.action.send(.getTradingInfo)
            }

        case .setMaxAmount:
            isSwapExactIn = true
            if tokenPay.token.isTokenADA {
                let maxAmount = tokenPay.token.amount - TokenManager.shared.minimumAdaValue
                tokenPay.amount = maxAmount.formatSNumber(usesGroupingSeparator: false, maximumFractionDigits: tokenPay.token.decimals)
            } else {
                tokenPay.amount = tokenPay.token.amount.formatSNumber(usesGroupingSeparator: false, maximumFractionDigits: tokenPay.token.decimals)
            }

        case .setHalfAmount:
            isSwapExactIn = true
            tokenPay.amount = (tokenPay.token.amount / 2).formatSNumber(usesGroupingSeparator: false, maximumFractionDigits: tokenPay.token.decimals)

        case let .amountPayChanged(amount),
            let .amountReceiveChanged(amount):
            getTradingInfo(amount: amount)

        case .getTradingInfo:
            let amount = isSwapExactIn ? tokenPay.amount : tokenReceive.amount
            getTradingInfo(amount: amount.doubleValue)

        case .autoRouter,
            .routeSelected,
            .safeMode:
            break

        case let .showSelectToken(isTokenPay):
            selectTokenVM.selectToken(tokens: [isTokenPay ? tokenPay.token : tokenReceive.token])
            self.isSelectTokenPay = isTokenPay
            withAnimation {
                isShowSelectToken = true
            }
        case .recheckUnSafeSlippage:
            warningInfo.removeAll { warning in
                if case SwapTokenViewModel.WarningInfo.unsafeSlippageTolerance = warning {
                    return true
                } else {
                    return false
                }
            }
            if swapSetting.slippageSelectedValue() >= 50 {
                warningInfo.append(.unsafeSlippageTolerance(percent: "50"))
            }
        case .reloadBalance:
            let tokens = TokenManager.shared.normalTokens
            var isReloadSelectToken: Bool = false
            if let tokenPayChange = tokens.first(where: { $0.uniqueID == tokenPay.uniqueID }), tokenPay.token.amount != tokenPayChange.amount {
                tokenPay.token = tokenPayChange
                isReloadSelectToken = true
            }
            if let tokenReceiveChange = tokens.first(where: { $0.uniqueID == tokenReceive.uniqueID }), tokenReceive.token.amount != tokenReceiveChange.amount {
                tokenReceive.token = tokenReceiveChange
                isReloadSelectToken = true
            }
            
            if isReloadSelectToken {
                selectTokenVM.getTokens()
                generateErrorInfo()
            }

        case .hiddenSelectToken:
            selectTokenVM.resetState()

        case .cancelTimeInterval:
            workItem?.cancel()
        case .startTimeInterval:
            workItem?.cancel()
            workItem = DispatchWorkItem() { [weak self] in
                guard let self = self else { return }
                self.action.send(.getTradingInfo)
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(Self.TIME_INTERVAL), execute: workItem!)
        }
    }
    
    @MainActor
    private func generateWarningInfo() async {
        var warningInfo: [WarningInfo] = []
        
        if let priceImpact = iosTradeEstimate?.avgPriceImpact, priceImpact >= 5 {
            warningInfo.append(.highPriceImpact(percent: "5"))
        }
        if swapSetting.slippageSelectedValue() >= 50 {
            warningInfo.append(.unsafeSlippageTolerance(percent: "50"))
        }
        if tokenPay.currencySymbol == functionalToken {
            warningInfo.append(.functionalTokenPay(ticker: tokenPay.adaName, project: functionalName))
        }
        if tokenReceive.currencySymbol == functionalToken {
            warningInfo.append(.functionalTokenReceive(ticker: tokenReceive.adaName, project: functionalName))
        }
        if await AppSetting.shared.isSuspiciousToken(currencySymbol: tokenPay.currencySymbol) {
            warningInfo.append(.suspiciousTokenPay(policyId: tokenPay.currencySymbol))
        }
        if await AppSetting.shared.isSuspiciousToken(currencySymbol: tokenReceive.currencySymbol) {
            warningInfo.append(.suspiciousTokenReceive(policyId: tokenReceive.currencySymbol))
        }
        if let migrate = migrateTokens.first(where: { (old, new) in old.currencySymbol == tokenPay.currencySymbol }) {
            warningInfo.append(.tokenPayMigration(projectName: tokenPay.token.projectName, tokenName: migrate.new.adaName, policyId: migrate.new.currencySymbol))
        }
        if let migrate = migrateTokens.first(where: { (old, new) in old.currencySymbol == tokenReceive.currencySymbol }) {
            warningInfo.append(.tokenPayMigration(projectName: tokenReceive.token.projectName, tokenName: migrate.new.adaName, policyId: migrate.new.currencySymbol))
        }
        
        if !tokenPay.token.hasMetaData {
            warningInfo.append(.unregisteredTokenPay(policyID: tokenPay.currencySymbol))
        }
        
        if !tokenReceive.token.hasMetaData {
            warningInfo.append(.unregisteredTokenReceive(policyID: tokenReceive.currencySymbol))
        }
        
        if tokenPay.token.decimals == 0 || tokenReceive.token.decimals == 0 {
            warningInfo.append(.indivisibleToken)
        }
        self.warningInfo = warningInfo
        self.isExpand = [:]
    }
    
    @MainActor
    private func generateErrorInfo() {
        let payAmount = tokenPay.amount.doubleValue
        let receiveAmount = tokenReceive.amount.doubleValue
        errorInfo = nil
        if isSwapExactIn {
            if payAmount > tokenPay.token.amount {
                errorInfo = .insufficientBalance(name: tokenPay.token.adaName)
            }
        } else {
            if receiveAmount > tokenReceive.token.amount {
                errorInfo = .notEnoughAmountInPool(name: tokenReceive.token.adaName)
            }
        }
    }
    
    private func getTradingInfo(amount: Double) {
        workItem?.cancel()
        tradeInfoTask?.cancel()
        tradeInfoTask = Task { [weak self] in
            guard let self = self else { return }
            do {
                await MainActor.run {
                    self.tokenPay.calculateSubPrice()
                    self.tokenReceive.subPrice = 0
                    withAnimation {
                        self.isGettingTradeInfo = true
                    }
                }
                
                let amount = amount * pow(10, Double(isSwapExactIn ? tokenPay.token.decimals : tokenReceive.token.decimals))
                let request = EstimationRequest()
                    .with {
                        $0.amount = amount.formatSNumber(usesGroupingSeparator: false, maximumFractionDigits: 0)
                        $0.token_in = (self.isSwapExactIn ? self.tokenPay.token.uniqueID : self.tokenReceive.token.uniqueID).toPolicyIdWithoutDot
                        $0.token_out = (self.isSwapExactIn ? self.tokenReceive.token.uniqueID : self.tokenPay.token.uniqueID).toPolicyIdWithoutDot
                        $0.slippage = self.swapSetting.slippageSelectedValue()
                        $0.exclude_protocols = self.swapSetting.excludedPools
                        $0.amount_in_decimal = false
                    }
                
                async let priceUSDTokenPay = withTimeout(10) {
                    await self.getTokenPriceUsd(token: self.tokenPay)
                }
                
                async let priceUSDTokenReceive = withTimeout(10) {
                    await self.getTokenPriceUsd(token: self.tokenReceive)
                }
                
                let results = try? await (priceUSDTokenPay, priceUSDTokenReceive)
                self.tokenPay.priceUsd = results?.0 ?? 0
                self.tokenReceive.priceUsd = results?.1 ?? 0
                
                let info: EstimationResponse?
                if amount > 0 {
                    do {
                        let jsonData = try await SwapTokenAPIRouter.estimate(request: request).async_request()
                        try APIRouterCommon.parseDefaultErrorMessage(jsonData)
                        info = Mapper<EstimationResponse>().map(JSON: jsonData.dictionaryObject ?? [:])
                    } catch {
                        if Task.isCancelled { return }
                        info = nil
                        self.workItem?.cancel()
                        
                        await self.processResultTradingInfo(info: info)
                        
                        throw error
                    }
                } else {
                    info = nil
                }
                
                try Task.checkCancellation()
                
                await self.processResultTradingInfo(info: info)
                
                await MainActor.run {
                    self.action.send(.startTimeInterval)
                }
            } catch is CancellationError {
                print("Task cancelled")
            } catch {
                await MainActor.run {
                    self.bannerState.showBannerError(error.rawError)
                }
            }
        }
    }
    
    private func processResultTradingInfo(info: EstimationResponse?) async {
        await MainActor.run {
            self.iosTradeEstimate = info
            if self.isSwapExactIn {
                let outputAmount = info?.amountOut.toExact(decimal: Double(self.tokenReceive.token.decimals)) ?? 0
                self.tokenReceive.amount = outputAmount == 0 ? "" : outputAmount.formatSNumber(maximumFractionDigits: self.tokenReceive.token.decimals)
            } else {
                let outputAmount = info?.amountOut.toExact(decimal: Double(self.tokenPay.token.decimals)) ?? 0
                self.tokenPay.amount = outputAmount == 0 ? "" : outputAmount.formatSNumber(maximumFractionDigits: self.tokenReceive.token.decimals)
            }
            
            tokenPay.calculateSubPrice()
            tokenReceive.calculateSubPrice()
        }
        
        await generateWarningInfo()
        generateErrorInfo()
        
        await MainActor.run {
            withAnimation {
                self.isGettingTradeInfo = false
            }
        }
    }
    
    func swapToken() async throws -> String {
        guard let iosTradeEstimate = iosTradeEstimate else { return "" }
        guard let address: String = UserInfo.shared.minWallet?.address else { throw AppGeneralError.localErrorLocalized(message: "Wallet not found") }
        
        let estimate = BuildTxRequest.Estimate()
            .with {
                $0.amount = iosTradeEstimate.amountIn
                $0.token_in = iosTradeEstimate.tokenIn
                $0.token_out = iosTradeEstimate.tokenOut
                $0.slippage = swapSetting.slippageSelectedValue()
                $0.exclude_protocols = swapSetting.excludedPools
                $0.partner = ""
            }
        
        let request = BuildTxRequest()
            .with {
                $0.sender = address
                $0.min_amount_out = iosTradeEstimate.minAmountOut
                $0.amount_in_decimal = iosTradeEstimate.amountInDecimal
                $0.estimate = estimate
            }
        
        let jsonData = try await SwapTokenAPIRouter.buildTX(request: request).async_request()
        try APIRouterCommon.parseDefaultErrorMessage(jsonData)
        guard let tx = jsonData["cbor"].string, !tx.isEmpty else { throw AppGeneralError.localErrorLocalized(message: "Transaction not found") }
        return tx
    }
    
    private func getTokenPriceUsd(token: WrapTokenSend) async -> Double {
        guard !token.token.isTokenADA else { return AppSetting.shared.currencyInADA }
        guard token.priceUsd == 0 else { return token.priceUsd }
        let jsonData = try? await MinWalletAPIRouter.detailAsset(id: token.currencySymbol + token.tokenName).async_request()
        let asset = Mapper<TopAssetsResponse.AssetMetric>.init().map(JSON: jsonData?.dictionaryObject ?? [:])
        return asset?.price ?? 0
    }
    
    var minimumMaximumAmount: Double {
        iosTradeEstimate?.minAmountOut.gkDoubleValue ?? 0
    }
    
    var enableSwap: Bool {
        if !understandingWarning && showUnderstandingCheckbox {
            return false
        }
        if errorInfo != nil {
            return false
        }
        
        if tokenPay.amount.doubleValue.isZero || tokenReceive.amount.doubleValue.isZero {
            return false
        }
        
        return true
    }
    
    var showUnderstandingCheckbox: Bool {
        let warningInfo = warningInfo.filter { warning in
            switch warning {
            case .indivisibleToken, .unregisteredTokenPay, .unregisteredTokenReceive:
                return false
            default:
                return true
            }
        }
        
        return !warningInfo.isEmpty
    }
}


extension SwapTokenViewModel {
    enum Action {
        case autoRouter
        case safeMode
        case selectToken(token: TokenProtocol?)
        case routeSelected
        case setMaxAmount
        case setHalfAmount
        case amountPayChanged(amount: Double)
        case amountReceiveChanged(amount: Double)
        case swapToken
        case getTradingInfo
        case showSelectToken(isTokenPay: Bool)
        case recheckUnSafeSlippage
        case resetSwap
        case reloadBalance
        case hiddenSelectToken
        case cancelTimeInterval
        case startTimeInterval
    }
}


extension SwapTokenViewModel {
    enum WarningInfo: Hashable {
        ///priceImpact >= IMPACT_TIERS[0] and settings.safeMode and hasExchange
        case highPriceImpact(percent: String)
        ///slippage >= UNSAFE_SLIPPAGE_TOLERANCE and safeMode
        case unsafeSlippageTolerance(percent: String)
        ///Token exists in FUNCTIONAL_ASSETS
        case functionalTokenPay(ticker: String, project: String)
        case functionalTokenReceive(ticker: String, project: String)
        ///Token exists in blacklistPolicyIds
        case suspiciousTokenPay(policyId: String)
        case suspiciousTokenReceive(policyId: String)
        ///priceImpact >= IMPACT_TIERS[0] and settings.safeMode and hasExchange
        case tokenPayMigration(projectName: String, tokenName: String, policyId: String)
        case tokenReceiveMigration(projectName: String, tokenName: String, policyId: String)
        ///Token exists in MIGRATED_TOKENS
        case unregisteredTokenPay(policyID: String)
        case unregisteredTokenReceive(policyID: String)
        ///decimals == 0
        case indivisibleToken
        
        var title: LocalizedStringKey {
            switch self {
            case .highPriceImpact:
                "High price impact"
            case .unsafeSlippageTolerance:
                "Unsafe slippage tolerance"
            case .functionalTokenPay, .functionalTokenReceive:
                "Functional token"
            case .suspiciousTokenPay,
                .suspiciousTokenReceive:
                "Suspicious token"
            case .tokenPayMigration,
                .tokenReceiveMigration:
                "Token migration"
            case .unregisteredTokenPay, .unregisteredTokenReceive:
                "Unregistered token"
            case .indivisibleToken:
                "Indivisible Token"
            }
        }
        
        var content: LocalizedStringKey {
            switch self {
            case let .highPriceImpact(percent):
                "Price impact is more than \(percent)%, make sure to check the price before submitting the transaction."
            case let .unsafeSlippageTolerance(percent):
                "Slippage tolerance is over \(percent)%. You can adjust it in trade "
            case let .functionalTokenPay(ticker, project),
                let .functionalTokenReceive(ticker, project):
                " Trading \(ticker) token on Minswap may lead to a loss of underlying assets on \(project)."
            case let .suspiciousTokenPay(policyId),
                let .suspiciousTokenReceive(policyId):
                "Make sure to double-check the policy Id: \(policyId)."
            case let .tokenPayMigration(projectName, policyId, tokenName),
                let .tokenReceiveMigration(projectName, policyId, tokenName):
                "This project token is migrated to a new token, you can exchange your old token on \(projectName) app. The new token has policyID \(policyId) and tokenName \(tokenName)."
            case let .unregisteredTokenPay(policyID),
                let .unregisteredTokenReceive(policyID):
                "This token isn't registered on Cardano Token Registry. Please make sure to double check the policy Id: \(policyID)"
            case .indivisibleToken:
                "Certain tokens on the Cardano blockchain are designed as indivisible. This means each token must be used, transferred, or traded as a whole unit."
            }
        }
    }
    
    enum ErrorInfo {
        case insufficientBalance(name: String)
        case notEnoughAmountInPool(name: String)
        
        var content: LocalizedStringKey {
            switch self {
            case let .insufficientBalance(name):
                return "Insufficient \(name) balance"
            case let .notEnoughAmountInPool(name):
                return "Not enough \(name) amount in pool"
            }
        }
    }
}

extension EstimationResponse {
    var priceImpactColor: (Color, Color) {
        if avgPriceImpact < 2 {
            return (.colorInteractiveToneSuccess, .colorSurfaceSuccess)
        } else if avgPriceImpact > 5 {
            return (.colorInteractiveToneDanger, .colorSurfaceDanger)
        } else {
            return (.colorInteractiveToneWarning, .colorSurfaceWarningDefault)
        }
    }
}

fileprivate func withTimeout<T>(
    _ seconds: Double,
    operation: @escaping @Sendable () async throws -> T
) async throws -> T {
    try await withThrowingTaskGroup(of: T.self) { group in
        group.addTask {
            try await operation()
        }
        
        group.addTask {
            try await Task.sleep(nanoseconds: UInt64(seconds * 1_000_000_000))
            throw NSError(domain: "Timeout", code: -1)
        }
        
        let result = try await group.next()!
        group.cancelAll()
        return result
    }
}
