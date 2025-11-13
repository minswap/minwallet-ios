import ObjectMapper
import Foundation


struct AssetData: Mappable, Hashable {
    var currency_symbol: String = ""
    var token_name: String = ""
    var is_verified: Bool = false
    var metadata: Metadata?
    var social_links: SocialLinksRaw?

    init() {}

    init?(map: Map) {}

    mutating func mapping(map: Map) {
        currency_symbol <- map["currency_symbol"]
        token_name <- map["token_name"]
        is_verified <- map["is_verified"]
        metadata <- map["metadata"]
        social_links <- map["social_links"]
    }
}
extension AssetData {
    struct Metadata: Mappable, Hashable {
        var name: String?
        var url: String?
        var ticker: String?
        var decimals: Int?
        var description: String?
        var logo: String?

        init() {}

        init?(map: Map) {}

        mutating func mapping(map: Map) {
            name <- map["name"]
            url <- map["url"]
            ticker <- map["ticker"]
            decimals <- (map["decimals"], GKMapFromJSONToInt)
            description <- map["description"]
            logo <- map["logo"]
        }
    }

    struct SocialLinksRaw: Mappable, Hashable {
        var website: String?
        var twitter: String?
        var telegram: String?
        var coinGecko: String?
        var coinMarketCap: String?
        var discord: String?

        init() {}

        init?(map: Map) {}

        mutating func mapping(map: Map) {
            website <- map["website"]
            twitter <- map["twitter"]
            telegram <- map["telegram"]
            coinGecko <- map["coingecko"]
            coinMarketCap <- map["coin_market_cap"]
            discord <- map["discord"]
        }
    }
}


extension AssetData: TokenProtocol {
    var currencySymbol: String { currency_symbol }
    var tokenName: String { token_name }
    var isVerified: Bool { false }
    var ticker: String { metadata?.ticker ?? UserInfo.TOKEN_NAME_DEFAULT[uniqueID] ?? "" }
    var projectName: String { "" }
    var percentChange: Double { 0 }
    var priceValue: Double { 0 }
    var amount: Double { 0 }
    var subPriceValue: Double { 0 }
    var category: [String] { [] }
    var socialLinks: [SocialLinks: String] {
        let socialLinks = social_links ?? .init()
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

    var decimals: Int { 0 }

    var nftDisplayName: String { metadata?.name ?? "" }
    var nftImage: String { metadata?.url ?? "" }
    var hasMetaData: Bool { true }
}
