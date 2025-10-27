import Foundation


public
    struct GKeychainStore
{
    // MARK: Types
    public
        enum KeychainError: Error
    {
        case noPassword
        case unexpectedPasswordData
        case unexpectedItemData
        case unhandledError(status: OSStatus)
    }
    
    // MARK: Properties
    
    let service: String
    private(set) var key: String
    let accessGroup: String?
    
    // MARK: Intialization
    
    public
        init(service: String, key: String, accessGroup: String? = nil)
    {
        self.service = service
        self.key = key
        self.accessGroup = accessGroup
    }
    
    // MARK: Keychain access
    
    public
        func read() throws -> String
    {
        /*
         Build a query to find the item that matches the service, key and
         access group.
         */
        var query = Self.keychainQuery(withService: service, key: self.key, accessGroup: accessGroup)
        query[kSecMatchLimit as String] = kSecMatchLimitOne
        query[kSecReturnAttributes as String] = kCFBooleanTrue
        query[kSecReturnData as String] = kCFBooleanTrue
        
        // Try to fetch the existing keychain item that matches the query.
        var queryResult: AnyObject?
        let status = withUnsafeMutablePointer(to: &queryResult) {
            SecItemCopyMatching(query as CFDictionary, UnsafeMutablePointer($0))
        }
        
        // Check the return status and throw an error if appropriate.
        guard status != errSecItemNotFound else { throw KeychainError.noPassword }
        guard status == noErr else { throw KeychainError.unhandledError(status: status) }
        
        // Parse the password string from the query result.
        guard let existingItem = queryResult as? [String: AnyObject],
            let valueData = existingItem[kSecValueData as String] as? Data,
            let value = String(data: valueData, encoding: String.Encoding.utf8)
        else {
            throw KeychainError.unexpectedPasswordData
        }
        
        return value
    }
    
    public
        func save(_ value: String) throws
    {
        // Encode the password into an Data object.
        let encodedValue = value.data(using: String.Encoding.utf8)!
        
        do {
            // Check for an existing item in the keychain.
            try _ = read()
            
            // Update the existing item with the new value.
            var attributesToUpdate = [String: AnyObject]()
            attributesToUpdate[kSecValueData as String] = encodedValue as AnyObject?
            
            let query = Self.keychainQuery(withService: service, key: self.key, accessGroup: accessGroup)
            let status = SecItemUpdate(query as CFDictionary, attributesToUpdate as CFDictionary)
            
            // Throw an error if an unexpected status was returned.
            guard status == noErr else { throw KeychainError.unhandledError(status: status) }
        } catch KeychainError.noPassword {
            /*
             No value was found in the keychain. Create a dictionary to save
             as a new keychain item.
             */
            var newItem = Self.keychainQuery(withService: service, key: self.key, accessGroup: accessGroup)
            newItem[kSecValueData as String] = encodedValue as AnyObject?
            
            // Add a the new item to the keychain.
            let status = SecItemAdd(newItem as CFDictionary, nil)
            
            // Throw an error if an unexpected status was returned.
            guard status == noErr else { throw KeychainError.unhandledError(status: status) }
        }
    }
    
    mutating
        func renameKey(_ newKeyName: String) throws
    {
        // Try to update an existing item with the new key name.
        var attributesToUpdate = [String: AnyObject]()
        attributesToUpdate[kSecAttrAccount as String] = newKeyName as AnyObject?
        
        let query = Self.keychainQuery(withService: service, key: self.key, accessGroup: accessGroup)
        let status = SecItemUpdate(query as CFDictionary, attributesToUpdate as CFDictionary)
        
        // Throw an error if an unexpected status was returned.
        guard status == noErr || status == errSecItemNotFound else { throw KeychainError.unhandledError(status: status) }
        
        self.key = newKeyName
    }
    
    func deleteItem() throws {
        // Delete the existing item from the keychain.
        let query = Self.keychainQuery(withService: service, key: self.key, accessGroup: accessGroup)
        let status = SecItemDelete(query as CFDictionary)
        
        // Throw an error if an unexpected status was returned.
        guard status == noErr || status == errSecItemNotFound else { throw KeychainError.unhandledError(status: status) }
    }
    
    static
        func valueItems(forService service: String, accessGroup: String? = nil) throws -> [GKeychainStore]
    {
        // Build a query for all items that match the service and access group.
        var query = Self.keychainQuery(withService: service, accessGroup: accessGroup)
        query[kSecMatchLimit as String] = kSecMatchLimitAll
        query[kSecReturnAttributes as String] = kCFBooleanTrue
        query[kSecReturnData as String] = kCFBooleanFalse
        
        // Fetch matching items from the keychain.
        var queryResult: AnyObject?
        let status = withUnsafeMutablePointer(to: &queryResult) {
            SecItemCopyMatching(query as CFDictionary, UnsafeMutablePointer($0))
        }
        
        // If no items were found, return an empty array.
        guard status != errSecItemNotFound else { return [] }
        
        // Throw an error if an unexpected status was returned.
        guard status == noErr else { throw KeychainError.unhandledError(status: status) }
        
        // Cast the query result to an array of dictionaries.
        guard let resultData = queryResult as? [[String: AnyObject]] else { throw KeychainError.unexpectedItemData }
        
        // Create a `GKeychainStore` for each dictionary in the query result.
        var valueItems = [GKeychainStore]()
        for result in resultData {
            guard let key = result[kSecAttrAccount as String] as? String else { throw KeychainError.unexpectedItemData }
            
            let valueItem = GKeychainStore(service: service, key: key, accessGroup: accessGroup)
            valueItems.append(valueItem)
        }
        
        return valueItems
    }
    
    // MARK: Convenience
    
    private static
        func keychainQuery(withService service: String, key: String? = nil, accessGroup: String? = nil) -> [String: AnyObject]
    {
        var query = [String: AnyObject]()
        query[kSecClass as String] = kSecClassGenericPassword
        query[kSecAttrService as String] = service as AnyObject?
        
        if let key = key {
            query[kSecAttrAccount as String] = key as AnyObject?
        }
        
        if let accessGroup = accessGroup {
            query[kSecAttrAccessGroup as String] = accessGroup as AnyObject?
        }
        
        return query
    }
}

// MARK: - Constants
extension GKeychainStore {
    // MARK: Unique ID
    public
        static let UNIQUE_ID_KEYCHAIN_SERVICE = "UniqueIdService"
    public
        static let UNIQUE_ID_KEYCHAIN_KEY = "uniqueId"
}
