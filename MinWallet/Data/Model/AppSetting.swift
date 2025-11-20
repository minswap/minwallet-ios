import SwiftUI
import Combine
import OneSignalFramework


class AppSetting: ObservableObject {
    static let USER_NAME = "minWallet"
    
    static let shared: AppSetting = .init()
    
    var extraSafeArea: CGFloat {
        safeArea > 44 ? 32 : 12
    }
    
    var biometricAuthentication: BiometricAuthentication = .init() {
        willSet {
            objectWillChange.send()
        }
    }
    
    let objectWillChange = PassthroughSubject<Void, Never>()
    
    var safeArea: CGFloat = UIApplication.safeArea.top
    var swipeEnabled = true
    
    var rootScreen: MainCoordinatorViewModel.Screen = .policy(.splash)
    {
        willSet {
            objectWillChange.send()
        }
    }
    
    @UserDefault("first_time", defaultValue: true)
    var isFirstTimeRunApp: Bool {
        willSet {
            objectWillChange.send()
        }
    }
    
    @UserDefault("enable_audio", defaultValue: false)
    var enableAudio: Bool {
        willSet {
            objectWillChange.send()
        }
    }
    
    @UserDefault("enable_notification", defaultValue: true)
    var enableNotification: Bool {
        willSet {
            objectWillChange.send()
        }
    }
    
    @UserDefault("language", defaultValue: Language.english.rawValue)
    var language: String {
        willSet {
            objectWillChange.send()
        }
    }
    
    @UserDefault("currency", defaultValue: Currency.usd.rawValue)
    var currency: String {
        willSet {
            objectWillChange.send()
        }
    }
    
    @UserDefault("timezone", defaultValue: TimeZone.local.rawValue)
    var timeZone: String {
        willSet {
            objectWillChange.send()
        }
    }
    
    @UserDefault("userInterfaceStyle", defaultValue: Appearance.system.rawValue)
    var userInterfaceStyle: Int {
        willSet {
            objectWillChange.send()
        }
    }
    
    @UserDefault("security_type", defaultValue: 0)
    private var securityType: Int {
        willSet {
            objectWillChange.send()
        }
    }
    
    @UserDefault("is_login", defaultValue: false)
    var isLogin: Bool {
        willSet {
            objectWillChange.send()
        }
    }
    
    //TODO: Remove
    @UserDefault("fake_wallet_address", defaultValue: "")
    var fakeWalletAddress: String {
        willSet {
            objectWillChange.send()
        }
    }
    
    var authenticationType: AuthenticationType {
        get { AuthenticationType(rawValue: securityType) ?? .biometric }
        set { securityType = newValue.rawValue }
    }
    
    lazy var bip0039: [String] = {
        guard let fileURL = Bundle.main.url(forResource: "bip0039", withExtension: "txt") else { return [] }
        do {
            return try String(contentsOf: fileURL, encoding: .utf8).split(separator: "\n").map { String($0) }
        } catch {
            return []
        }
    }()

    private lazy var suspiciousToken: [String] = []
    
    private init() {
        rootScreen = isLogin ? .home : (isFirstTimeRunApp ? .policy(.splash) : .gettingStarted)
    }
    
    var showBiometryChanged: Bool = false {
        willSet {
            Task {
                await MainActor.run {
                    objectWillChange.send()
                }
            }
        }
    }
    
    var openSettingForSetupFaceId: Bool = false {
        willSet {
            Task {
                await MainActor.run {
                    objectWillChange.send()
                }
            }
        }
    }
    
    var messageForSetting: String = "" {
        willSet {
            Task {
                await MainActor.run {
                    objectWillChange.send()
                }
            }
        }
    }
    
    @MainActor func deleteAccount() {
        isLogin = false
        
        TokenManager.reset()
        try? AppSetting.deletePasswordToKeychain(username: AppSetting.USER_NAME)
        UserDataManager.shared.tokenRecentSearch = []
        UserDataManager.shared.tokenFav = []
        UserDataManager.shared.notificationGenerateAuthHash = nil
        OneSignal.Notifications.clearAll()
        OneSignal.logout()
        
        authenticationType = .biometric
        enableNotification = true
        timeZone = TimeZone.local.rawValue
    }
    
    func isSuspiciousToken(currencySymbol: String) async -> Bool {
        guard !currencySymbol.isEmpty else { return false }
        guard suspiciousToken.isEmpty else { return suspiciousToken.contains(currencySymbol) }
        guard let url = URL(string: MinWalletConstant.suspiciousTokenURL) else { return false }
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            let tokensScam = String(decoding: data, as: UTF8.self).split(separator: "\n").map { String($0) }
            AppSetting.shared.suspiciousToken = tokensScam
            return tokensScam.contains(currencySymbol)
        } catch {
            return false
        }
    }
}


//MARK: Theme
extension AppSetting {
    var appearance: Appearance {
        Appearance(rawValue: userInterfaceStyle) ?? .system
    }
    
    func initAppearanceStyle() {
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
            windowScene.windows.forEach { window in
                switch Appearance(rawValue: userInterfaceStyle) {
                case .system:
                    window.overrideUserInterfaceStyle = .unspecified
                case .light:
                    window.overrideUserInterfaceStyle = .light
                case .dark:
                    window.overrideUserInterfaceStyle = .dark
                default:
                    window.overrideUserInterfaceStyle = .unspecified
                }
            }
        }
    }
    
    func applyAppearanceStyle(_ selectedAppearance: Appearance) {
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
            windowScene.windows.forEach { window in
                switch selectedAppearance {
                case .system:
                    userInterfaceStyle = Appearance.system.rawValue
                    window.overrideUserInterfaceStyle = .unspecified
                case .light:
                    userInterfaceStyle = Appearance.light.rawValue
                    window.overrideUserInterfaceStyle = .light
                case .dark:
                    userInterfaceStyle = Appearance.dark.rawValue
                    window.overrideUserInterfaceStyle = .dark
                }
            }
        }
    }
}


extension AppSetting {
    static func getPasswordFromKeychain(username: String) throws -> String {
        do {
            let passwordItem = GKeychainStore(
                service: MinWalletConstant.keyChainService,
                key: username,
                accessGroup: MinWalletConstant.keyChainAccessGroup
            )
            let keychainPassword = try passwordItem.read()
            return keychainPassword.isBlank ? (UserDefaults.standard.string(forKey: username) ?? "") : keychainPassword
        } catch {
            return UserDefaults.standard.string(forKey: username) ?? ""
        }
    }
    
    static func savePasswordToKeychain(username: String, password: String) throws {
        do {
            let passwordItem = GKeychainStore(
                service: MinWalletConstant.keyChainService,
                key: username,
                accessGroup: MinWalletConstant.keyChainAccessGroup
            )
            
            try passwordItem.save(password)
        } catch {
            UserDefaults.standard.set(password, forKey: username)
        }
    }
    
    static func deletePasswordToKeychain(username: String) throws {
        do {
            let passwordItem = GKeychainStore(
                service: MinWalletConstant.keyChainService,
                key: username,
                accessGroup: MinWalletConstant.keyChainAccessGroup
            )
            
            try passwordItem.deleteItem()
            UserDefaults.standard.removeObject(forKey: username)
        } catch {
            UserDefaults.standard.removeObject(forKey: username)
        }
    }
    
    var password: String {
        switch authenticationType {
        case .password:
            (try? AppSetting.getPasswordFromKeychain(username: AppSetting.USER_NAME)) ?? ""
        case .biometric:
            MinWalletConstant.passDefaultForFaceID
        }
    }
}

extension AppSetting {
    enum AuthenticationType: Int {
        case biometric
        case password
    }
}


extension AppSetting {
    static let fakeWalletAddress: Bool = true
}
