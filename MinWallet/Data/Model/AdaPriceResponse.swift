import Foundation
import ObjectMapper
import Then

struct AdaPriceResponse: Then {
    var currency: String?
    var value: Value = .init()
    
    init() {}
}

extension AdaPriceResponse {
    struct Value: Then {
        var change24h: Double = 0
        var price: Double = 0
        
        init() {}
    }
}

extension AdaPriceResponse: Mappable {
    init?(map: Map) {}
    
    mutating func mapping(map: Map) {
        currency <- map["currency"]
        value <- map["value"]
    }
}

extension AdaPriceResponse.Value: Mappable {
    init?(map: Map) {}
    
    mutating func mapping(map: Map) {
        change24h <- (map["change_24h"], GKMapFromJSONToDouble)
        price <- (map["price"], GKMapFromJSONToDouble)
    }
}
