import Foundation
import ObjectMapper
import Then

struct AssetsInput: Then {
    var term: String?
    var limit: Int = 20
    var onlyVerified: Bool?
    var searchAfter: [Any]?
    
    init() {}
}


struct AssetsResponse: Mappable {
    var searchAfter: [String]?
    var assets: [AssetData] = []
    
    init() {}
    init?(map: Map) {}
    
    mutating func mapping(map: Map) {
        searchAfter <- map["search_after"]
        assets <- map["assets"]
    }
}
