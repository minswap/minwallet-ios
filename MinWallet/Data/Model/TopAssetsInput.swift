import Foundation
import Then

struct TopAssetsInput: Then {
    var term: String?
    var limit: Int = 20
    var only_verified: Bool?
    var search_after: [Any]?
    var sort_direction: SortDirection?
    var sort_field: SortField?
    var favorite_asset_ids: [String]?
    var filter_small_liquidity: Bool?
    
    init() {}
}

extension TopAssetsInput {
    enum SortDirection: String {
        case asc
        case desc
    }
    
    enum SortField: String {
        case price_change_1h
        case price_change_24h
        case price_change_7d
        case volume_1h
        case volume_24h
        case volume_7d
        case liquidity
        case market_cap
        case fully_diluted
        case total_supply
        case circulating_supply
    }
}
