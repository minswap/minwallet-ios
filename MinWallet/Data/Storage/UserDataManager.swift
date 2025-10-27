import Foundation
import Then


class UserDataManager {
    static let DEVICE_TOKEN = "DEVICE_TOKEN"
    static let TOKEN_RECENT_SEARCH = "TOKEN_RECENT_SEARCH"
    static let ONE_SIGNAL_HASH_TOKEN = "ONE_SIGNAL_HASH_TOKEN"
    static let TOKEN_FAVORITE = "TOKEN_FAVORITE"
    
    static let shared = UserDataManager()
    
    private var defaults: UserDefaults!
    
    private init() {
        defaults = UserDefaults.standard
    }
    
    var deviceToken: String? {
        get {
            return defaults!.string(forKey: Self.DEVICE_TOKEN)
        }
        set(newValue) {
            defaults!.set(newValue, forKey: Self.DEVICE_TOKEN)
        }
    }
    
    var tokenRecentSearch: [String] {
        get {
            return (defaults!.array(forKey: Self.TOKEN_RECENT_SEARCH) as? [String]) ?? []
        }
        set(newValue) {
            defaults!.set(newValue, forKey: Self.TOKEN_RECENT_SEARCH)
        }
    }
    
    var notificationGenerateAuthHash: String? {
        get {
            return defaults!.string(forKey: Self.ONE_SIGNAL_HASH_TOKEN)
        }
        set(newValue) {
            defaults!.set(newValue, forKey: Self.ONE_SIGNAL_HASH_TOKEN)
        }
    }
    
    var tokenFav: [String] {
        get {
            return (defaults!.array(forKey: Self.TOKEN_FAVORITE) as? [String]) ?? []
        }
        set(newValue) {
            defaults!.set(newValue, forKey: Self.TOKEN_FAVORITE)
        }
    }
}
