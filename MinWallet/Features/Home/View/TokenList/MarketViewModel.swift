import SwiftUI
import Foundation
import Combine
import OneSignalFramework
import ObjectMapper
import Then


@MainActor
class MarketViewModel: ObservableObject {
    
    @Published
    var tokens: [TokenProtocol] = []
    @Published
    var showSkeleton: Bool? = nil
    
    private var input: TopAssetsInput = .init()
    private var searchAfter: [Any]? = nil
    private var hasLoadMore = false
    private var isFetching: Bool = false
    private let limit: Int = 20
    
    init() {}
    
    private var isFirstTime: Bool = true
    
    func getTokens(isLoadMore: Bool = false) async {
        if showSkeleton == nil {
            showSkeleton = true
        }
        isFetching = true
        
        input = TopAssetsInput()
            .with({
                $0.limit = limit
                $0.only_verified = false
                $0.favorite_asset_ids = nil
                $0.sort_field = .volume_usd_24h
                $0.sort_direction = .desc
                if isLoadMore, let searchAfter = searchAfter {
                    $0.search_after = searchAfter
                }
            })
        
        if isFirstTime {
            async let tokenRaw = try? await MinWalletAPIRouter.topAssets(input: input).async_request()
            async let getPortfolioOverviewAndYourToken: Void? = try? await TokenManager.shared.getPortfolioOverviewAndYourToken()
            
            let results = await (tokenRaw, getPortfolioOverviewAndYourToken)
            let tokens = (Mapper<TopAssetsResponse>().map(JSON: results.0?.dictionaryObject ?? [:])) ?? .init()
            
            let _tokens = tokens.assets
            self.tokens = _tokens
            searchAfter = tokens.search_after
            hasLoadMore = _tokens.count >= limit || searchAfter != nil
        } else {
            let jsonData = try? await MinWalletAPIRouter.topAssets(input: input).async_request()
            
            let tokenRaw = Mapper<TopAssetsResponse>().map(JSON: jsonData?.dictionaryObject ?? [:]) ?? .init()
            
            let _tokens = tokenRaw.assets
            
            if isLoadMore {
                tokens += _tokens
            } else {
                tokens = _tokens
            }
            searchAfter = tokenRaw.search_after
            hasLoadMore = _tokens.count >= limit || searchAfter != nil
        }
        showSkeleton = false
        isFetching = false
        isFirstTime = false
    }
    
    func loadMoreData(item: TokenProtocol) {
        guard hasLoadMore, !isFetching else { return }
        let thresholdIndex = tokens.index(tokens.endIndex, offsetBy: -5)
        if tokens.firstIndex(where: { $0.uniqueID == item.uniqueID }) == thresholdIndex {
            Task {
                await getTokens(isLoadMore: true)
            }
        }
    }
}


extension MarketViewModel {
    static func getTopAssetsFav() async -> [TopAssetsResponse.AssetMetric] {
        let favAssetIds: [String] = UserInfo.shared.tokensFav.sorted(by: { $0.dateAdded > $1.dateAdded }).map { $0.currencySymbol + $0.tokenName }
        guard !favAssetIds.isEmpty else { return [] }
        
        let input = TopAssetsInput()
            .with({
                $0.limit = 100
                $0.only_verified = false
                $0.favorite_asset_ids = favAssetIds
            })
        
        let tokenRaw = try? await MinWalletAPIRouter.topAssets(input: input).async_request()
        let tokens = Mapper<TopAssetsResponse>.init().map(JSON: tokenRaw?.dictionaryObject ?? [:]) ?? .init()
        
        guard !tokens.assets.isEmpty else { return [] }
        
        let indexMap = Dictionary(uniqueKeysWithValues: favAssetIds.enumerated().map { ($1, $0) })
        let sortedAssets = tokens.assets.sorted {
            let lhs = indexMap[$0.currencySymbol + $0.tokenName] ?? Int.max
            let rhs = indexMap[$1.currencySymbol + $1.tokenName] ?? Int.max
            return lhs < rhs
        }
        return sortedAssets
    }
}
