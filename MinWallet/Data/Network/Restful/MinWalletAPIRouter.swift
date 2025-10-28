import Foundation
import Alamofire


enum MinWalletAPIRouter: DomainAPIRouter {
    case portfolio
    case chartInfo(id: String, period: ChartPeriod)
    case assets(input: AssetsInput)
    case topAssets(input: TopAssetsInput)
    case detailAsset(id: String)

    func path() -> String {
        switch self {
        case .portfolio:
            return "/v1/portfolio/tokens"
        case let .chartInfo(tokenId, _):
            return "/v1/assets/\(tokenId)/price/timeseries"
        case .assets:
            return "/v1/assets"
        case .topAssets:
            return "/v1/assets/metrics"
        case let .detailAsset(id):
            return "/v1/assets/\(id)/metrics"
        }
    }

    func method() -> HTTPMethod {
        switch self {
        case .portfolio:
            return .get
        case .chartInfo:
            return .get
        case .assets:
            return .get
        case .topAssets:
            return .post
        case .detailAsset:
            return .get
        }
    }

    func parameters() -> Parameters {
        var params = Parameters()

        switch self {
        case .portfolio:
            params["address"] = UserInfo.shared.minWallet?.address
        case let .chartInfo(id, period):
            params["id"] = id
            params["period"] = period.rawValue
        case let .assets(input):
            if let term = input.term, !term.isBlank {
                params["term"] = term
            }
            params["limit"] = input.limit
            input.onlyVerified.map {
                params["only_verified"] = $0
            }
            if let searchAfter = input.searchAfter, !searchAfter.isEmpty {
                params["search_after"] = searchAfter
            }
        case let .topAssets(input):
            if let term = input.term, !term.isBlank {
                params["term"] = term
            }
            params["limit"] = input.limit
            input.only_verified.map {
                params["only_verified"] = $0
            }
            if let search_after = input.search_after, !search_after.isEmpty {
                params["search_after"] = search_after
            }
            input.sort_direction.map {
                params["sort_direction"] = $0.rawValue
            }
            input.sort_field.map {
                params["sort_field"] = $0.rawValue
            }
            input.filter_small_liquidity.map {
                params["filter_small_liquidity"] = $0
            }
            input.favorite_asset_ids.map {
                params["favorite_asset_ids"] = $0
            }
        case .detailAsset:
            break
        }
        return params
    }
}
