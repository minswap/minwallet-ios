import Foundation
import Then
import ObjectMapper


struct TokenFavourite: Then {
    var dateAdded: Double = Date().timeIntervalSince1970
    var currencySymbol: String = ""
    var tokenName: String = ""
    var adaName: String = ""

    init() {}

    var uniqueID: String {
        if currencySymbol.isEmpty && tokenName.isEmpty {
            return "lovelace"
        }

        if currencySymbol.isEmpty {
            return tokenName
        }
        if tokenName.isEmpty {
            return currencySymbol
        }

        return currencySymbol + "." + tokenName
    }
}

extension TokenFavourite: Mappable {
    init?(map: Map) {}

    mutating func mapping(map: Map) {
        dateAdded <- (map["dateAdded"], GKMapFromJSONToDouble)
        currencySymbol <- (map["currencySymbol"], GKMapFromJSONToString)
        tokenName <- (map["tokenName"], GKMapFromJSONToString)
        adaName <- (map["adaName"], GKMapFromJSONToString)
    }
}
