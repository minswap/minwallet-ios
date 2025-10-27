import SwiftUI
import Foundation
import Combine
import MinWalletAPI
import OneSignalFramework


@MainActor
class HomeViewModel: ObservableObject {
    
    @Published
    var tabType: TokenListView.TabType = .market
    @Published
    private var showSkeletonDic: [TokenListView.TabType: Bool] = [:]
    @Published
    var tabTypes: [TokenListView.TabType] = []
    @Published
    var scrollIndex: Int = 0
    
    private var cancellables: Set<AnyCancellable> = []
    private var timerReloadBalance: AnyCancellable?
    private var timerReloadMarket: AnyCancellable?
    
    @Published
    var marketViewModel: MarketViewModel = .init()
    @Published
    var yourTokenViewModel: YourTokenViewModel = .init(type: .yourToken)
    @Published
    var nftViewModel: YourTokenViewModel = .init(type: .nft)
    
    @Published
    var favTokenIds: [String] = []
    
    deinit {
        timerReloadBalance?.cancel()
        timerReloadMarket?.cancel()
    }
    
    init() {
        guard AppSetting.shared.isLogin else { return }
        Self.generateTokenHash()
        
        $tabType
            .removeDuplicates()
            .debounce(for: .milliseconds(200), scheduler: DispatchQueue.main)
            .sink { [weak self] newValue in
                guard let self = self else { return }
                Task {
                    //self.tabType = newValue
                    await self.getTokens()
                    let tabTypes: [TokenListView.TabType?] = [
                        .market,
                        !TokenManager.shared.normalTokens.isEmpty ? .yourToken : nil,
                        !TokenManager.shared.nftTokens.isEmpty ? .nft : nil,
                    ]
                    self.tabTypes = tabTypes.compactMap({ $0 })
                }
            }
            .store(in: &cancellables)
        
        Timer.publish(every: 5, on: .main, in: .common)
            .autoconnect()
            .throttle(for: .seconds(5), scheduler: RunLoop.main, latest: true)
            .removeDuplicates()
            .sink { [weak self] time in
                guard let self = self else { return }
                withAnimation {
                    self.scrollIndex = (self.scrollIndex + 1) % 3
                }
            }
            .store(in: &cancellables)
    }
    
    private func createTimerReloadBalance() {
        timerReloadBalance?.cancel()
        timerReloadBalance = Timer.publish(every: TokenManager.TIME_RELOAD_BALANCE, on: .main, in: .common)
            .autoconnect()
            .throttle(for: .seconds(TokenManager.TIME_RELOAD_BALANCE), scheduler: RunLoop.main, latest: true)
            .removeDuplicates()
            .sink { [weak self] time in
                guard let self = self, !TokenManager.shared.isLoadingPortfolioOverviewAndYourToken else { return }
                guard AppSetting.shared.isLogin
                else {
                    self.timerReloadBalance?.cancel()
                    return
                }
                Task {
                    switch self.tabType {
                    case .market:
                        try? await TokenManager.shared.getPortfolioOverviewAndYourToken()
                    case .yourToken, .nft:
                        await self.getTokens()
                    }
                }
            }
        
        timerReloadMarket?.cancel()
        timerReloadMarket = Timer.publish(every: TokenManager.TIME_RELOAD_MARKET, on: .main, in: .common)
            .autoconnect()
            .throttle(for: .seconds(TokenManager.TIME_RELOAD_MARKET), scheduler: RunLoop.main, latest: true)
            .removeDuplicates()
            .sink { [weak self] time in
                guard let self = self else { return }
                guard AppSetting.shared.isLogin
                else {
                    self.timerReloadMarket?.cancel()
                    return
                }
                Task {
                    switch self.tabType {
                    case .market:
                        await self.getTokens()
                    case .yourToken,
                        .nft:
                        break
                    }
                }
            }
    }
    
    private func getTokens(isLoadMore: Bool = false) async {
        timerReloadBalance?.cancel()
        timerReloadMarket?.cancel()
        
        if showSkeletonDic[.market] == nil {
            withAnimation {
                showSkeletonDic[.market] = !isLoadMore
            }
        }
        
        switch tabType {
        case .market:
            await marketViewModel.getTokens()
        case .yourToken:
            await yourTokenViewModel.getTokens()
        case .nft:
            await nftViewModel.getTokens()
        }
        
        if showSkeletonDic[.market] == true {
            withAnimation {
                showSkeletonDic[.market] = false
            }
        }
        createTimerReloadBalance()
    }
    
    static func generateTokenHash() {
        guard let address = UserInfo.shared.minWallet?.address, !address.isBlank else { return }
        Task {
            async let notificationGenerateAuthHashAsync = MinWalletService.shared.mutation(mutation: NotificationGenerateAuthHashMutation(identifier: address))?.notificationGenerateAuthHash
            async let skateAddressAsync = MinWalletService.shared.fetch(query: GetSkateAddressQuery(address: address))?.getStakeAddress
            
            let value = try? await (notificationGenerateAuthHashAsync, skateAddressAsync)
            
            if let token = value?.0, !token.isBlank, let skateAddress = value?.1, !skateAddress.isBlank, AppSetting.shared.enableNotification {
                UserDataManager.shared.notificationGenerateAuthHash = token
                OneSignal.login(externalId: skateAddress, token: token)
            }
        }
    }
}

extension HomeViewModel {
    var showSkeleton: Bool {
        showSkeletonDic[.market] ?? true
    }
    
    var countToken: Int? {
        switch tabType {
        case .yourToken:
            yourTokenViewModel.tokens.count
        case .nft:
            nftViewModel.tokens.count
        default:
            nil
        }
    }
    
    func showSkeleton(tabType: TokenListView.TabType) {
        switch tabType {
        case .market:
            if marketViewModel.showSkeleton == nil {
                marketViewModel.showSkeleton = true
            }
        case .yourToken:
            if yourTokenViewModel.showSkeleton == nil {
                yourTokenViewModel.showSkeleton = true
            }
        case .nft:
            if nftViewModel.showSkeleton == nil {
                nftViewModel.showSkeleton = true
            }
        }
    }
}
