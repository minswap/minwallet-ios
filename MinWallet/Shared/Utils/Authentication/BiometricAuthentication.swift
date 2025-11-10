import SwiftUI
import LocalAuthentication


class BiometricAuthentication {
    private static let KEY_ACCOUNT = "org.minswap.MinWallet.BiometricAuthentication.Account"
    
    private var loginReason: LocalizedStringKey {
        switch biometricType {
            case .touchID:
                return "Touch ID"
            case .faceID:
                return "Face ID"
#if swift(>=5.9)
            case .opticID:
                return "Optic ID"
#endif
            case .none:
                return ""
            @unknown default:
                return ""
        }
    }
    
    var displayName: LocalizedStringKey {
        switch biometricType {
            case .touchID:
                return "Touch ID"
            case .faceID:
                return "Face ID"
#if swift(>=5.9)
            case .opticID:
                return "Optic ID"
#endif
            case .none:
                return ""
            @unknown default:
                return ""
        }
    }
    
    var biometricType: LABiometryType {
        let context = LAContext()
        var error: NSError?
        context.canEvaluatePolicy(.deviceOwnerAuthentication, error: &error)
        return context.biometryType
    }
    
    init() { }
    
    static func setupBiometric() async throws {
        try BiometricVault.ensureDeviceSecure()
        try await BiometricVault.generateAndStoreSymKeyAsync(account: BiometricAuthentication.KEY_ACCOUNT)
        
        _ = try await BiometricVault.readSecretAsync(
            account: BiometricAuthentication.KEY_ACCOUNT,
            prompt: "Authenticate to confirm biometric setup"
        )
    }
    
    static func resetupBiometric() async throws {
        try BiometricVault.ensureDeviceSecure()
        try await BiometricVault.generateAndStoreSymKeyAsync(account: BiometricAuthentication.KEY_ACCOUNT)
    }
    
    static func authenticateUser() async throws {
        do {
            _ = try await BiometricVault.readSecretAsync(
                account: BiometricAuthentication.KEY_ACCOUNT,
                prompt: "Verify your identity to proceed"
            )
        } catch {
            if let error = error as? BiometricVaultError {
                switch error {
                    case .itemNotFound:
                        AppSetting.shared.showBiometryChanged = true
                        throw BiometricVaultError.ignore
                    case .passcodeNotSet:
                        AppSetting.shared.messageForSetting = BiometricVaultError.passcodeNotSet.localizedDescription
                        AppSetting.shared.openSettingForSetupFaceId = true
                        throw BiometricVaultError.ignore
                    default:
                        throw error
                }
            } else {
                throw error
            }
        }
    }
    
    static func deleteBiometric() async {
        try? await BiometricVault.deleteSecretAsync(account: BiometricAuthentication.KEY_ACCOUNT)
    }
}

extension BiometricAuthentication {
    enum ErrorType: LocalizedStringKey, CaseIterable {
        case userCancel = "Please accept with Face ID/Touch ID"
        case userFallback = "Enter password to continue"
        case passcodeNotSet = "Authentication cannot be initiated because a passcode has not been set up on the device."
        case authenticationFailed = "Authentication invalid, please try again later"
        case biometryNotAvailable = "Face ID/Touch ID not available"
        case biometryNotEnrolled = "Face ID/Touch ID not installed"
        case biometryLockout = "Face ID/Touch ID is locked"
        case touchIDNotAvailable = "Touch ID not available"
        case permissions = "Please grant biometric permission to the app to enable Face ID/Touch ID login"
        case requireLogin = "You must log in with a successful password to use this feature."
    }
}
