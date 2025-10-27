import Foundation


struct MinWalletConstant {
    static let minGraphURL = GetInfoDictionaryString(for: "MIN_GRAPH_URL", true)
    static let transactionURL = GetInfoDictionaryString(for: "MIN_TRANSACTION_URL", true)
    static let adaHandleURL = GetInfoDictionaryString(for: "MIN_ADA_HANDLE_URL", true)
    static let keyChainService = GetInfoDictionaryString(for: "MIN_KEYCHAIN_SERVICE_NAME")
    static let keyChainAccessGroup = GetInfoDictionaryString(for: "MIN_KEYCHAIN_ACCESS_GROUP")
    static let passDefaultForFaceID = GetInfoDictionaryString(for: "MIN_PASS_DEFAULT_FOR_FACE_ID")
    static let networkID = GetInfoDictionaryString(for: "MIN_PUBLIC_NETWORK_ID")
    static let minToken = GetInfoDictionaryString(for: "MIN_MIN_TOKEN")
    static let lpV1CurrencySymbol = GetInfoDictionaryString(for: "MIN_CURRENCY_SYMBOL_LP_V1")
    static let adaToken = GetInfoDictionaryString(for: "MIN_ADA_TOKEN")
    static let mintToken = GetInfoDictionaryString(for: "MIN_MINT_TOKEN")
    static let adaCurrency = GetInfoDictionaryString(for: "MIN_ADA_CURRENCY")
    static let minOneSignalAppID = GetInfoDictionaryString(for: "MIN_ONE_SIGNAL_APP_ID")
    static let minswapScheme = "minswap"
    static let addressPrefix = GetInfoDictionaryString(for: "MIN_ADDRESS_PREFIX")
    static let adaHandleRegex = #"^\$[a-z0-9._-]+$"#
    static let IPFS_PREFIX = "ipfs://"
    static let IPFS_GATEWAY = "https://ipfs.minswap.org/ipfs/"
    static let suspiciousTokenURL = "https://raw.githubusercontent.com/cardano-galactic-police/suspicious-tokens/refs/heads/main/tokens.txt"
    static let minPolicyURL = GetInfoDictionaryString(for: "MIN_POLICY_URL", true)
    static let minAssetURL = GetInfoDictionaryString(for: "MIN_ASSET_URL", true)
    static let minAggURL = GetInfoDictionaryString(for: "MIN_AGG_URL", true)
    static let minLockAggSource = Bundle.main.boolValue(forInfoPlistKey: "MIN_LOCK_AGGREGATOR_SOURCE")
    
    private init() {
        
    }
    
}


private func GetInfoDictionaryString(for key: String, _ removingBackslashes: Bool = false) -> String {
    let ret = Bundle.main.infoDictionary?[key] as! String
    if removingBackslashes {
        return ret.replacingOccurrences(of: "\\", with: "")
    } else {
        return ret
    }
}


extension Bundle {
    func boolValue(forInfoPlistKey key: String, default defaultValue: Bool = false) -> Bool {
        guard let value = object(forInfoDictionaryKey: key) else { return defaultValue }
        
        if let num = value as? NSNumber {
            return num.boolValue
        }
        if let str = value as? String {
            switch str.trimmingCharacters(in: .whitespacesAndNewlines).lowercased() {
            case "yes", "true", "1": return true
            case "no", "false", "0": return false
            default: return Bool(str) ?? defaultValue
            }
        }
        return defaultValue
    }
}
