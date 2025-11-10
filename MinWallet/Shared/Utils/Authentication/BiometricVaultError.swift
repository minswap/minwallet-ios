import LocalAuthentication
import Security
import CryptoKit
import SwiftUI


enum BiometricVaultError: LocalizedError {
    case userCancel
    case userFallback
    case passcodeNotSet
    case authenticationFailed
    case biometryNotAvailable
    case biometryNotEnrolled
    case biometryLockout
    case itemNotFound
    case permissions
    case keychain(status: OSStatus)
    case crypto
    case ignore
    
    var content: LocalizedStringKey {
        switch self {
        case .userCancel:
            "Please accept with Face ID/Touch ID"
        case .userFallback:
            "Enter password to continue"
        case .passcodeNotSet:
            "Authentication cannot be initiated because a passcode has not been set up on the device."
        case .authenticationFailed:
            "Authentication invalid, please try again later"
        case .biometryNotAvailable:
            "Face ID/Touch ID not available"
        case .biometryNotEnrolled:
            "Face ID/Touch ID not installed"
        case .biometryLockout:
            "Face ID/Touch ID is locked"
        case .itemNotFound:
            "Face ID/Touch ID not available"
        case .permissions:
            "Please grant biometric permission to the app to enable Face ID/Touch ID login"
        case .keychain:
            "Something went wrong"
        case .crypto, .ignore:
            "Something went wrong"
        }
    }
    
    var errorDescription: String? { 
        self.content.toString()
    }
}

struct BiometricVault {
    static func storeSecret(_ data: Data, account: String) throws {
        let access = try makeAccessControlBiometryCurrentSet()
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: account,
            kSecAttrAccessControl as String: access,
            kSecValueData as String: data,
        ]
        SecItemDelete(query as CFDictionary)
        let status = SecItemAdd(query as CFDictionary, nil)
        guard status == errSecSuccess else { throw BiometricVaultError.keychain(status: status) }
    }
    
    static func readSecret(account: String, prompt: String) throws -> Data {
        let ctx = LAContext()
        ctx.localizedReason = prompt
        try preflightDeviceSecurity(context: ctx)
        
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: account,
            kSecReturnData as String: true,
            kSecUseAuthenticationContext as String: ctx,
        ]
        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)
        switch status {
        case errSecSuccess:
            guard let data = result as? Data else { throw BiometricVaultError.itemNotFound }
            return data
        case errSecItemNotFound:
            throw BiometricVaultError.itemNotFound
        case errSecAuthFailed:
            throw BiometricVaultError.permissions
        case errSecInteractionNotAllowed:
            throw BiometricVaultError.biometryNotAvailable
        case errSecUserCanceled:
            throw BiometricVaultError.userCancel
        case errSecNotAvailable:
            throw BiometricVaultError.itemNotFound
        default:
            throw BiometricVaultError.keychain(status: status)
        }
    }
    
    static func deleteSecret(account: String) throws {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: account,
        ]
        let status = SecItemDelete(query as CFDictionary)
        guard status == errSecSuccess || status == errSecItemNotFound else {
            throw BiometricVaultError.keychain(status: status)
        }
    }
    
    static func generateAndStoreSymKey(account: String) throws {
        let key = SymmetricKey(size: .bits256)
        try storeSecret(key.withUnsafeBytes { Data($0) }, account: account)
    }
    
    static func encryptWithStoredKey(account: String, prompt: String, plaintext: Data) throws -> Data {
        let keyData = try readSecret(account: account, prompt: prompt)
        let key = SymmetricKey(data: keyData)
        guard let sealed = try? AES.GCM.seal(plaintext, using: key) else {
            throw BiometricVaultError.crypto
        }
        return sealed.combined!  // nonce + ciphertext + tag
    }
    
    static func decryptWithStoredKey(account: String, prompt: String, combined: Data) throws -> Data {
        let keyData = try readSecret(account: account, prompt: prompt)
        let key = SymmetricKey(data: keyData)
        let box = try AES.GCM.SealedBox(combined: combined)
        return try AES.GCM.open(box, using: key)
    }
    
    static func ensureDeviceSecure() throws {
        let ctx = LAContext()
        try preflightDeviceSecurity(context: ctx)
    }
    
    private static func preflightDeviceSecurity(context: LAContext) throws {
        var err: NSError?
        let canDeviceAuth = context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &err)
        if !canDeviceAuth {
            if let laErr = err as? LAError {
                switch laErr.code {
                case .passcodeNotSet: throw BiometricVaultError.passcodeNotSet
                case .biometryNotAvailable: throw BiometricVaultError.biometryNotAvailable
                case .biometryNotEnrolled: throw BiometricVaultError.biometryNotEnrolled
                case .biometryLockout: throw BiometricVaultError.biometryLockout
                default: break
                }
            }
        }
    }
    
    private static func makeAccessControlBiometryCurrentSet() throws -> SecAccessControl {
        var error: Unmanaged<CFError>?
        guard
            let ac = SecAccessControlCreateWithFlags(
                nil,
                kSecAttrAccessibleWhenPasscodeSetThisDeviceOnly,
                SecAccessControlCreateFlags.biometryCurrentSet,
                &error
            )
        else {
            throw error!.takeRetainedValue() as Error
        }
        return ac
    }
}

extension BiometricVault {
    public static func storeSecretAsync(_ data: Data, account: String) async throws {
        return try await withCheckedThrowingContinuation { cont in
            DispatchQueue.global(qos: .utility)
                .async {
                    do {
                        try storeSecret(data, account: account)
                        cont.resume()
                    } catch {
                        cont.resume(throwing: error)
                    }
                }
        }
    }
    
    static func readSecretAsync(account: String, prompt: String) async throws -> Data {
        try await withCheckedThrowingContinuation { cont in
            DispatchQueue.global(qos: .userInitiated)
                .async {
                    do {
                        let data = try BiometricVault.readSecret(account: account, prompt: prompt)
                        cont.resume(returning: data)
                    } catch {
                        cont.resume(throwing: error)
                    }
                }
        }
    }
    
    static func deleteSecretAsync(account: String) async throws {
        try await withCheckedThrowingContinuation { cont in
            DispatchQueue.global(qos: .userInitiated)
                .async {
                    do {
                        try BiometricVault.deleteSecret(account: account)
                        cont.resume(returning: ())
                    } catch {
                        cont.resume(throwing: error)
                    }
                }
        }
    }
    
    public static func generateAndStoreSymKeyAsync(account: String) async throws {
        return try await withCheckedThrowingContinuation { cont in
            DispatchQueue.global(qos: .utility)
                .async {
                    do {
                        try generateAndStoreSymKey(account: account)
                        cont.resume()
                    } catch {
                        cont.resume(throwing: error)
                    }
                }
        }
    }
    
    public static func encryptWithStoredKeyAsync(account: String, prompt: String, plaintext: Data) async throws -> Data {
        return try await withCheckedThrowingContinuation { cont in
            DispatchQueue.global(qos: .userInitiated)
                .async {
                    do {
                        // readSecret will display biometric prompt (may block inside but we're off-main)
                        let keyData = try readSecret(account: account, prompt: prompt)
                        let key = SymmetricKey(data: keyData)
                        let sealed = try AES.GCM.seal(plaintext, using: key)
                        guard let combined = sealed.combined else {
                            cont.resume(throwing: BiometricVaultError.crypto)
                            return
                        }
                        cont.resume(returning: combined)
                    } catch {
                        cont.resume(throwing: error)
                    }
                }
        }
    }
    public static func decryptWithStoredKeyAsync(account: String, prompt: String, combined: Data) async throws -> Data {
        return try await withCheckedThrowingContinuation { cont in
            DispatchQueue.global(qos: .userInitiated)
                .async {
                    do {
                        let keyData = try readSecret(account: account, prompt: prompt)
                        let key = SymmetricKey(data: keyData)
                        let box = try AES.GCM.SealedBox(combined: combined)
                        let plaintext = try AES.GCM.open(box, using: key)
                        cont.resume(returning: plaintext)
                    } catch {
                        cont.resume(throwing: error)
                    }
                }
        }
    }
}
