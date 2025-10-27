import Foundation
import MinWalletAPI
import Combine
import ObjectMapper


@MainActor
class TokenManager: ObservableObject {
    
    static let TIME_RELOAD_BALANCE: TimeInterval = 20
    static let TIME_RELOAD_MARKET: TimeInterval = 5 * 60
    
    static var shared: TokenManager = .init()
    
    let reloadBalance: PassthroughSubject<Void, Never> = .init()
    
    var isLoadingPortfolioOverviewAndYourToken: Bool = false
    
    ///Cached your token, include normal + lp tokens + nft
    private(set) var yourTokens: WalletAssetPosition? {
        willSet {
            objectWillChange.send()
        }
    }
    
    var netAdaValue: Double = 0 {
        willSet {
            objectWillChange.send()
        }
    }
    
    var pnl24HPercent: Double = 0 {
        willSet {
            objectWillChange.send()
        }
    }
    
    var adaValue: Double = 0 {
        willSet {
            objectWillChange.send()
        }
    }
    
    var minimumAdaValue: Double = 0 {
        willSet {
            objectWillChange.send()
        }
    }
    
    var tokenAda: TokenProtocol {
        yourTokens?.assets.first { $0.isTokenADA } ?? TokenDefault(symbol: "", tName: "", minName: "Cardano", decimal: 6)
    }
    
    private init() {}
    
    func getPortfolioOverviewAndYourToken() async throws -> Void {
        isLoadingPortfolioOverviewAndYourToken = true
        async let getYourTokenAsync: Void? = TokenManager.getYourToken().map { _ in return () }
        async let fetchMinimumAdaValueAsync: Void? = fetchMinimumAdaValue()
        
        let _ = try await [getYourTokenAsync, fetchMinimumAdaValueAsync]
        isLoadingPortfolioOverviewAndYourToken = false
        reloadBalance.send(())
    }
    
    private func fetchMinimumAdaValue() async throws -> Void {
        do {
            guard let address = UserInfo.shared.minWallet?.address else { return }
            let minimumAda = try await MinWalletService.shared.fetch(query: GetMinimumLovelaceQuery(address: address))
            minimumAdaValue = (minimumAda?.getMinimumLovelace.doubleValue ?? 0) / 1_000_000
        } catch {
            minimumAdaValue = 0
        }
    }
    
    func tokenById(tokenID: String) -> TokenProtocol? {
        normalTokens.first { $0.uniqueID == tokenID }
    }
}

extension TokenManager {
    static func reset() {
        TokenManager.shared = .init()
    }
    
    @discardableResult
    private static func getYourToken() async throws -> WalletAssetPosition? {
        let jsonData = try await MinWalletAPIRouter.portfolio.async_request()
        let tokens = Mapper<WalletAssetPosition>().map(JSON: jsonData["positions"].dictionaryObject ?? [:])
        
        TokenManager.shared.netAdaValue = tokens?.netAdaValue ?? 0
        TokenManager.shared.pnl24HPercent = tokens?.pnl24HPercent ?? 0
        TokenManager.shared.adaValue = tokens?.pnl24H ?? 0
        
        TokenManager.shared.yourTokens = tokens
        UserInfo.shared.adaHandleName = tokens?.nfts.first(where: { $0.currencySymbol == UserInfo.POLICY_ID })?.tokenName.adaName ?? ""
        return TokenManager.shared.yourTokens
    }
    
    ///Not include nft
    var normalTokens: [TokenProtocol] {
        return (yourTokens?.assets ?? []) + (yourTokens?.lpTokens ?? [])
    }
    
    var nftTokens: [TokenProtocol] {
        return yourTokens?.nfts ?? []
    }
    
    var hasTokenOrNFT: Bool {
        return !normalTokens.isEmpty || !nftTokens.isEmpty
    }
}


extension TokenManager {
    ///Tx raw -> tx ID
    static func finalizeAndSubmit(txRaw: String) async throws -> String? {
        guard let wallet = UserInfo.shared.minWallet else { throw AppGeneralError.localErrorLocalized(message: "Wallet not found") }
        guard let witnessSet = signTx(wallet: wallet, password: AppSetting.shared.password, accountIndex: wallet.accountIndex, txRaw: txRaw)
        else { throw AppGeneralError.localErrorLocalized(message: "Sign transaction failed") }
        
        let data = try await MinWalletService.shared.mutation(mutation: FinalizeAndSubmitMutation(input: InputFinalizeAndSubmit(tx: txRaw, witnessSet: witnessSet)))
        return data?.finalizeAndSubmit
    }
    
    static func finalizeAndSubmitV2(txRaw: String) async throws -> String? {
        guard let wallet = UserInfo.shared.minWallet else { throw AppGeneralError.localErrorLocalized(message: "Wallet not found") }
        guard let witnessSet = signTx(wallet: wallet, password: AppSetting.shared.password, accountIndex: wallet.accountIndex, txRaw: txRaw)
        else { throw AppGeneralError.localErrorLocalized(message: "Sign transaction failed") }
        
        let jsonData = try await SwapTokenAPIRouter.signTX(cbor: txRaw, witness_set: witnessSet).async_request()
        try APIRouterCommon.parseDefaultErrorMessage(jsonData)
        return jsonData["tx_id"].string
    }
}
