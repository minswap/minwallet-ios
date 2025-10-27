import Foundation
import Then


extension OrderHistory {
    struct InputOutput: Hashable, Then, Identifiable {
        var id: String {
            asset.tokenId
        }
        
        var asset: Asset = .init()
        var amount: Double = 0
        var minimumAmount: Double = 0
        
        init() {}
        
        init(asset: Asset?, amount: Double, minimumAmount: Double = 0, amountInDecimal: Bool = false) {
            self.asset = asset ?? .init()
            self.amount = amountInDecimal ? amount : (amount.toExact(decimal: asset?.decimals ?? 0))
            self.minimumAmount = minimumAmount.toExact(decimal: asset?.decimals ?? 0)
        }
    }
}


extension OrderHistory.InputOutput {
    var currency: String {
        asset.adaName
    }
    
    var currencySymbol: String {
        asset.token?.currencySymbol ?? ""
    }
    
    var tokenName: String {
        asset.token?.tokenName ?? ""
    }
    
    var decimals: Int {
        asset.token?.decimals ?? 0
    }
    
    var isVerified: Bool {
        asset.isVerified
    }
}
