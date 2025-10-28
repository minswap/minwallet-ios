import SwiftUI
import Combine
import OneSignalFramework


@MainActor
class YourTokenViewModel: ObservableObject {

    @Published
    var tokens: [TokenProtocol] = []
    @Published
    var showSkeleton: Bool? = nil

    private let type: TokenListView.TabType
    private var bag = Set<AnyCancellable>()

    init(type: TokenListView.TabType) {
        self.type = type

        NotificationCenter.default.publisher(for: .favDidChange)
            .receive(on: RunLoop.main)
            .sink { [weak self] _ in
                guard let self = self else { return }
                switch type {
                case .market:
                    break
                case .yourToken:
                    self.tokens = UserInfo.sortTokens(tokens: TokenManager.shared.normalTokens)
                case .nft:
                    break
                }
            }
            .store(in: &bag)
    }

    func getTokens() async {
        if showSkeleton == nil {
            showSkeleton = true
        }
        try? await Task.sleep(for: .milliseconds(300))
        try? await TokenManager.shared.getPortfolioOverviewAndYourToken()

        switch type {
        case .market:
            tokens = []

        case .yourToken:
            self.tokens = UserInfo.sortTokens(tokens: TokenManager.shared.normalTokens)

        case .nft:
            tokens = TokenManager.shared.yourTokens?.nfts ?? []
        }

        showSkeleton = false
    }
}
