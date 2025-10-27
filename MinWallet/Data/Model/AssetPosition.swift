import ObjectMapper
import Foundation


struct AssetPosition: Mappable {
    var asset: AssetData = .init()
    var price_usd: Double = 0
    var amount_position: Double = 0
    var amount_position_usd: Double = 0
    var pnl_24h_usd: Double = 0
    var pnl_24h_percent: Double = 0
    
    init() {}
    
    init?(map: Map) {}
    
    mutating func mapping(map: Map) {
        asset <- map["asset"]
        price_usd <- (map["price_usd"], GKMapFromJSONToDouble)
        amount_position <- (map["amount"], GKMapFromJSONToDouble)
        amount_position_usd <- (map["amount_usd"], GKMapFromJSONToDouble)
        pnl_24h_usd <- (map["pnl_24h_usd"], GKMapFromJSONToDouble)
        pnl_24h_percent <- (map["pnl_24h_percent"], GKMapFromJSONToDouble)
    }
}


extension AssetPosition: TokenProtocol {
    var currencySymbol: String { asset.currency_symbol }
    var tokenName: String { asset.token_name }
    var isVerified: Bool { asset.is_verified }
    var ticker: String { asset.metadata?.ticker ?? UserInfo.TOKEN_NAME_DEFAULT[uniqueID] ?? "" }
    var projectName: String { asset.metadata?.name ?? "" }
    var priceValue: Double { amount_position }
    var amount: Double { priceValue }
    var percentChange: Double { pnl_24h_percent }
    var subPriceValue: Double { amount_position_usd }
    
    var category: [String] { [] }
    
    var socialLinks: [SocialLinks: String] {
        let socialLinks = asset.social_links ?? .init()
        var links: [SocialLinks: String] = [:]
        if let coinGecko = socialLinks.coinGecko {
            links[.coinGecko] = coinGecko
        }
        if let coinMarketCap = socialLinks.coinMarketCap {
            links[.coinMarketCap] = coinMarketCap
        }
        if let discord = socialLinks.discord {
            links[.discord] = discord
        }
        if let telegram = socialLinks.telegram {
            links[.telegram] = telegram
        }
        if let telegram = socialLinks.telegram {
            links[.telegram] = telegram
        }
        if let twitter = socialLinks.twitter {
            links[.twitter] = twitter
        }
        if let website = socialLinks.website {
            links[.website] = website
        }
        links[.cardanoscan] = "https://cardanoscan.io/token/\(currencySymbol)\(tokenName)"
        links[.adaStat] = "https://adastat.net/tokens/\(currencySymbol)\(tokenName)"
        return links
    }
    
    var decimals: Int {
        asset.metadata?.decimals ?? 0
    }
    
    var hasMetaData: Bool {
        asset.metadata != nil
    }
}
