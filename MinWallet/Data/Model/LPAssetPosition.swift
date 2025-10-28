import ObjectMapper
import Foundation


struct LPAssetPosition: Mappable {
    var asset: AssetData = .init()
    var amount_position: Double = 0
    var amount_position_usd: Double = 0
    var pnl_24h_usd: Double = 0
    var pnl_24h_percent: Double = 0
    var pool_share: Double = 0
    var protocolSource: AggregatorSource?

    init() {}

    init?(map: Map) {}

    mutating func mapping(map: Map) {
        asset <- map["asset"]
        amount_position <- (map["amount"], GKMapFromJSONToDouble)
        amount_position_usd <- (map["amount_usd"], GKMapFromJSONToDouble)
        pnl_24h_usd <- (map["pnl_24h_usd"], GKMapFromJSONToDouble)
        pnl_24h_percent <- (map["pnl_24h_percent"], GKMapFromJSONToDouble)
        protocolSource <- (
            map["protocol"],
            GKMapFromJSONToType(fromJSON: { json in
                guard let source = json as? String, !source.isEmpty else { return nil }
                return .init(rawId: source)
            })
        )
    }
}


extension LPAssetPosition: TokenProtocol {
    var adaName: String {
        let ada: String? = {
            guard ticker.isBlank else { return ticker }
            if currencySymbol == MinWalletConstant.lpV1CurrencySymbol { return "LP" }
            if currencySymbol == MinWalletConstant.adaToken { return "ADA" }
            return UserInfo.TOKEN_NAME_DEFAULT[uniqueID] ?? tokenName.adaName ?? ""
        }()
        return [ada, protocolSource?.nameLP].compactMap({ $0 }).filter { !$0.isBlank }.joined(separator: " - ")
    }

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
