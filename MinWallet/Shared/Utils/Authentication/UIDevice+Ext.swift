import UIKit


extension UIDevice {
    public
        var uniqueId: String?
    {
        guard var uniqueId = self.identifierForVendor?.uuidString else { return nil }
        // Nếu không setup đủ Team & Keychain Access Group, thì chỉ trả ra `identifierForVendor` bth
        let keychainAccessGroup = MinWalletConstant.keyChainAccessGroup
        
        if let uniqueIdStore = try? GKeychainStore(
            service: GKeychainStore.UNIQUE_ID_KEYCHAIN_SERVICE,
            key: GKeychainStore.UNIQUE_ID_KEYCHAIN_KEY,
            accessGroup: keychainAccessGroup
        )
        .read() {
            uniqueId = uniqueIdStore
        } else {
            try? GKeychainStore(
                service: GKeychainStore.UNIQUE_ID_KEYCHAIN_SERVICE,
                key: GKeychainStore.UNIQUE_ID_KEYCHAIN_KEY,
                accessGroup: keychainAccessGroup
            )
            .save(uniqueId)
        }
        return uniqueId
    }
    
    private
        static var _currentUniqueId: String?
    
    public
        static var currentUniqueId: String?
    {
        if _currentUniqueId == nil {
            _currentUniqueId = current.uniqueId
        }
        return _currentUniqueId
    }
}
