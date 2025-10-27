import SwiftUI
import ObjectMapper
import Then


class UserInfo: ObservableObject {
    static let POLICY_ID: String = "f0ff48bbb7bbe9d59a40f1ce90e9e9d0ff5002ec48f232b49ca0fb9a"
    static let TOKEN_ADA: String = "lovelace"
    
    static let TOKEN_NAME_DEFAULT: [String: String] = [
        MinWalletConstant.adaToken: "ADA",
        MinWalletConstant.lpV1CurrencySymbol: "LP",
        MinWalletConstant.minToken: "MIN",
        MinWalletConstant.mintToken: "MINt",
    ]

    static let MIN_WALLET_KEY: String = "MIN_WALLET_KEY"
    
    static let shared: UserInfo = .init()
    
    @Published var minWallet: MinWallet?
    @Published var tokensFav: [TokenFavourite] = []
    
    private var tokenFavKey: String = ""
    
    @UserDefault("adaHandleName", defaultValue: "")
    var adaHandleName: String {
        willSet {
            objectWillChange.send()
        }
    }
    
    private init() {
        self.readMinWallet()
    }
    
    func saveWalletInfo(walletInfo: MinWallet) {
        guard let encoded = try? JSONEncoder().encode(walletInfo) else { return }
        UserDefaults.standard.set(encoded, forKey: Self.MIN_WALLET_KEY)
        
        self.minWallet = walletInfo
        tokenFavKey = walletInfo.address + "_" + UserDataManager.TOKEN_FAVORITE
        self.readTokenFav()
    }
    
    func deleteAccount() {
        minWallet = nil
        adaHandleName = ""
        tokenFavKey = ""
        UserDefaults.standard.removeObject(forKey: Self.MIN_WALLET_KEY)
    }
    
    private func readMinWallet() {
        guard let wallet = UserDefaults.standard.object(forKey: Self.MIN_WALLET_KEY) as? Data,
            let minWallet = try? JSONDecoder().decode(MinWallet.self, from: wallet)
        else { return }
        
        self.minWallet = minWallet
        tokenFavKey = minWallet.address + "_" + UserDataManager.TOKEN_FAVORITE
        self.readTokenFav()
    }
    
    var walletName: String {
        guard let name = minWallet?.walletName else { return "" }
        if name.count <= 16 {
            return name
        }
        
        let first5Characters = name.prefix(5)
        let last5Characters = name.suffix(5)
        return "\(first5Characters)...\(last5Characters)"
    }
    
    func tokenFavSelected(token: TokenProtocol, isAdd: Bool) {
        if isAdd {
            self.tokensFav.insert(
                TokenFavourite()
                    .with({
                        $0.currencySymbol = token.currencySymbol
                        $0.tokenName = token.tokenName
                        $0.adaName = token.adaName
                        $0.dateAdded = Date().timeIntervalSince1970
                    }), at: 0)
        } else {
            self.tokensFav = self.tokensFav.filter({ $0.uniqueID != token.uniqueID })
        }
        saveTokenFav()
        NotificationCenter.default.post(name: .favDidChange, object: nil)
    }
    
    private func readTokenFav() {
        guard let savedData = UserDefaults.standard.string(forKey: tokenFavKey),
            let tokens = Mapper<TokenFavourite>().mapArray(JSONString: savedData)
        else { return }
        self.tokensFav = tokens.sorted(by: { $0.dateAdded > $1.dateAdded })
    }
    
    private func saveTokenFav() {
        guard !tokensFav.isEmpty else {
            UserDefaults.standard.removeObject(forKey: tokenFavKey)
            return
        }
        let encoded = tokensFav.toJSONString()
        UserDefaults.standard.set(encoded, forKey: tokenFavKey)
    }
}

extension UserInfo {
    static func sortTokens(tokens: [TokenProtocol]) -> [TokenProtocol] {
        let favoriteIDs: Set<String> = Set(UserInfo.shared.tokensFav.map { $0.uniqueID })
        let tokenAda = tokens.filter { $0.isTokenADA }
        let favs = tokens.filter { favoriteIDs.contains($0.uniqueID) && !$0.isTokenADA }.sorted { $0.amount > $1.amount }
        let nonFavs = tokens.filter { !favoriteIDs.contains($0.uniqueID) && !$0.isTokenADA }
        
        return tokenAda + favs + nonFavs
    }
}
