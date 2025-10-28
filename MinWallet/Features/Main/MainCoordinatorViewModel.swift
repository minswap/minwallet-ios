import SwiftUI
import FlowStacks
import Apollo
import ApolloAPI


@MainActor
class MainCoordinatorViewModel: ObservableObject {
    @Published var routes: Routes<Screen> = []

    init() {}
}

extension MainCoordinatorViewModel {
    enum Screen: Hashable {
        case home
        case policy(PolicyConfirmView.ScreenType)
        case gettingStarted
        case tokenDetail(token: TokenProtocol)
        case about
        case changePassword
        case changePasswordSuccess(_ screenType: ChangePasswordSuccessView.ScreenType)
        case forgotPassword(_ screenType: ChangePasswordView.ScreenType)
        case createWallet(_ screen: CreateWalletScreen)
        case restoreWallet(_ screen: RestoreWalletScreen)
        case walletSetting(_ screen: WalletSettingScreen)
        case sendToken(_ screen: SendTokenScreen)
        case receiveToken(_ screen: ReceiveTokenView.ScreenType)
        case swapToken(_ screen: SwapTokenScreen)
        case searchToken
        case securitySetting(_ screen: SecuritySetting)
        case orderHistoryDetail(wrapOrder: WrapOrderHistory, onReloadOrder: (() -> Void)?)
        case orderHistory
        case scanQR
        case termOfService
    }
}

enum CreateWalletScreen: Hashable {
    case createWallet
    case seedPhrase
    case reInputSeedPhrase(seedPhrase: [String])
    case setupNickName(seedPhrase: [String])
    case biometricSetup(seedPhrase: [String], nickName: String)
    case createNewPassword(seedPhrase: [String], nickName: String)
    case createNewWalletSuccess
}

enum RestoreWalletScreen: Hashable {
    case restoreWallet
    case importFile
    case seedPhrase
    case setupNickName(fileContent: String, seedPhrase: [String])
    case biometricSetup(fileContent: String, seedPhrase: [String], nickName: String)
    case createNewPassword(fileContent: String, seedPhrase: [String], nickName: String)
    case createNewWalletSuccess
}

enum WalletSettingScreen: Hashable {
    case walletAccount
    case editNickName
    case changePassword
    case changePasswordSuccess
}

enum SendTokenScreen: Hashable, Identifiable {
    case sendToken(tokensSelected: [TokenProtocol], sendAll: Bool, screenType: SendTokenView.ScreenType)
    case toWallet(tokens: [WrapTokenSend], sendAll: Bool)
    case confirm(tokens: [WrapTokenSend], address: String, sendAll: Bool)
    case selectToken(
        tokensSelected: [TokenProtocol?],
        screenType: SelectTokenView.ScreenType,
        sourceScreenType: SendTokenView.ScreenType,
        onSelectToken: (([TokenProtocol], Bool) -> Void)?
    )

    var id: UUID { UUID() }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

    static func == (lhs: SendTokenScreen, rhs: SendTokenScreen) -> Bool {
        switch (lhs, rhs) {
        case (.sendToken, .sendToken),
            (.toWallet, .toWallet),
            (.confirm, .confirm),
            (.selectToken, .selectToken):
            return true
        default:
            return false
        }
    }
}

enum SwapTokenScreen: Hashable, Identifiable {
    var id: UUID { UUID() }

    case swapToken(token: TokenProtocol?)

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

    static func == (lhs: SwapTokenScreen, rhs: SwapTokenScreen) -> Bool {
        switch (lhs, rhs) {
        case (.swapToken, .swapToken):
            return true
        }
    }
}

enum SecuritySetting: Hashable {
    case authentication
    case createPassword(onCreatePassSuccess: CreatePassSuccess)
    case forgotPassword
}

extension SecuritySetting {
    struct CreatePassSuccess: Hashable {
        private var id = UUID().uuidString

        var onCreatePassSuccess: ((String) -> Void)?

        init(onCreatePassSuccess: ((String) -> Void)?) {
            self.onCreatePassSuccess = onCreatePassSuccess
        }

        static func == (lhs: SecuritySetting.CreatePassSuccess, rhs: SecuritySetting.CreatePassSuccess) -> Bool {
            lhs.id == rhs.id
        }

        func hash(into hasher: inout Hasher) {
            hasher.combine(id)
        }
    }
}

extension MainCoordinatorViewModel.Screen: Identifiable {
    var id: UUID { UUID() }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

    static func == (lhs: MainCoordinatorViewModel.Screen, rhs: MainCoordinatorViewModel.Screen) -> Bool {
        switch (lhs, rhs) {
        case (.home, .home),
            (.policy, .policy),
            (.gettingStarted, .gettingStarted),
            (.about, .about),
            (.changePassword, .changePassword),
            (.receiveToken, .receiveToken),
            (.searchToken, .searchToken),
            (.orderHistory, .orderHistory),
            (.scanQR, .scanQR),
            (.termOfService, .termOfService):
            return true

        case (.tokenDetail, .tokenDetail):
            return true
        case (.changePasswordSuccess(let screenType1), .changePasswordSuccess(let screenType2)):
            return screenType1 == screenType2

        case (.forgotPassword(let screenType1), .forgotPassword(let screenType2)):
            return screenType1 == screenType2

        case (.createWallet(let screen1), .createWallet(let screen2)):
            return screen1 == screen2

        case (.restoreWallet(let screen1), .restoreWallet(let screen2)):
            return screen1 == screen2

        case (.walletSetting(let screen1), .walletSetting(let screen2)):
            return screen1 == screen2

        case (.sendToken(let screen1), .sendToken(let screen2)):
            return screen1 == screen2

        case (.swapToken(let screen1), .swapToken(let screen2)):
            return screen1 == screen2

        case (.securitySetting(let setting1), .securitySetting(let setting2)):
            return setting1 == setting2

        case (.orderHistoryDetail, .orderHistoryDetail):
            return true

        default:
            return false
        }
    }
}
