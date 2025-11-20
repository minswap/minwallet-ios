import SwiftUI


@MainActor
class SendTokenViewModel: ObservableObject {
    
    @Published
    var tokens: [WrapTokenSend] = []
    @Published
    var screenType: SendTokenView.ScreenType = .normal
    @Published
    var selectTokenVM: SelectTokenViewModel = .init(screenType: .sendToken, sourceScreenType: .normal)
    @Published
    var isSendAll: Bool
    @Published
    var isCheckedWarning: Bool = false
    
    init(tokens: [TokenProtocol], isSendAll: Bool, screenType: SendTokenView.ScreenType) {
        self.screenType = screenType
        self.isSendAll = isSendAll
        
        if isSendAll {
            self.tokens = tokens.map({ token in
                let minValue = pow(10, Double(token.isTokenADA ? 6 : token.decimals) * -1)
                let amount = token.isTokenADA ? (max(token.amount - TokenManager.shared.minimumAdaValue, 0)) : token.amount
                let amountString = AmountTextField.formatCurrency(
                    String(amount),
                    minValue: minValue,
                    maxValue: amount,
                    minimumFractionDigits: token.isTokenADA ? 6 : token.decimals,
                    isCheckFractionalPart: true
                )
                return WrapTokenSend(token: token, amount: amountString)
            })
            self.tokens += TokenManager.shared.nftTokens.map({ item in
                let name = item.isAdaHandleName ? "$\(item.tokenName.adaName ?? "")" : (item.nftDisplayName.isBlank ? item.adaName : item.nftDisplayName)
                return WrapTokenSend(token: item, amount: name, isNFT: true)
            })
        } else {
            self.tokens = tokens.map({ WrapTokenSend(token: $0) })
        }
    }
    
    func addToken(tokens: [TokenProtocol]) {
        let currentAmountWithToken = self.tokens.reduce([:]) { result, wrapToken in
            result.appending([wrapToken.uniqueID: wrapToken.amount])
        }
        self.tokens = tokens.map { WrapTokenSend(token: $0, amount: currentAmountWithToken[$0.uniqueID] ?? "") }
    }
    
    func setMaxAmount(item: WrapTokenSend) {
        guard let index = tokens.firstIndex(where: { $0.id == item.id }) else { return }
        let decimals = tokens[index].token.decimals
        if tokens[index].token.isTokenADA {
            let maxAmount = item.token.amount - TokenManager.shared.minimumAdaValue
            tokens[index].amount = maxAmount.formatSNumber(usesGroupingSeparator: false, maximumFractionDigits: decimals)
        } else {
            tokens[index].amount = item.token.amount.formatSNumber(usesGroupingSeparator: false, maximumFractionDigits: decimals)
        }
    }
    
    var tokensToSend: [WrapTokenSend] {
        tokens.filter { (Decimal(string: $0.amount) ?? 0) > 0 || $0.isNFT }
    }
    
    var isValidTokenToSend: Bool {
        guard !isSendAll else { return isCheckedWarning }
        if tokens.count == 1 && tokens.first?.amount.isBlank == true {
            return false
        }
        return tokens.filter({ !$0.token.isTokenADA }).allSatisfy({ !$0.amount.isBlank })
    }
}


struct WrapTokenSend: Identifiable {
    let id: UUID = UUID()
    var token: TokenProtocol
    
    var amount: String = ""
    var isNFT: Bool = false
    var priceUsd: Double = 0
    var subPrice: Double = 0
    
    init(token: TokenProtocol, amount: String = "", isNFT: Bool = false) {
        self.token = token
        self.amount = amount
        self.isNFT = isNFT
    }
    
    var uniqueID: String {
        token.uniqueID
    }
    
    var currencySymbol: String {
        token.currencySymbol
    }
    
    var tokenName: String {
        token.tokenName
    }
    
    var adaName: String {
        let name = token.adaName
        if name.count > 6 {
            return name.prefix(6) + "..."
        } else {
            return name
        }
    }
}

extension WrapTokenSend {
    mutating func calculateSubPrice() {
        subPrice = priceUsd * amount.doubleValue
    }
}
