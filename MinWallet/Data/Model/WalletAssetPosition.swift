import ObjectMapper
import Foundation


struct WalletAssetPosition: Mappable {
    var nfts: [AssetData] = []
    var assets: [AssetPosition] = []
    private var lpAssets: [LPAsset] = []
    var lpTokens: [LPAssetPosition] = []
    
    var netAdaValue: Double = 0
    var pnl24H: Double = 0
    var pnl24HPercent: Double = 0
    
    init() {}
    
    init?(map: Map) {}
    
    mutating func mapping(map: Map) {
        nfts <- map["nft_positions"]
        assets <- map["asset_positions"]
        lpAssets <- map["lp_asset_positions"]
        
        lpTokens = lpAssets.compactMap({ $0.lp_asset_position })
        
        netAdaValue = assets.map { $0.value }.reduce(0, +) + lpTokens.map { $0.value }.reduce(0, +)
        pnl24H = assets.map { $0.pnl_24h }.reduce(0, +) + lpTokens.map { $0.pnl_24h }.reduce(0, +)
        
        pnl24HPercent = (netAdaValue - pnl24H == 0) ? 0 : ((pnl24H * 100) / (netAdaValue - pnl24H))
    }
}

extension WalletAssetPosition {
    struct LPAsset: Mappable {
        var lp_asset_position: LPAssetPosition?
        var asset_a_position: AssetPosition?
        var asset_b_position: AssetPosition?
        
        init() {}
        
        init?(map: Map) {}
        
        mutating func mapping(map: Map) {
            lp_asset_position <- map["lp_asset_position"]
            asset_a_position <- map["asset_a_position"]
            asset_b_position <- map["asset_b_position"]
        }
    }
}
