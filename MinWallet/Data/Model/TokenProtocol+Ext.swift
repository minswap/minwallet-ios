import SwiftUI
import Then
import MinWalletAPI

struct TokenProtocolDefault: TokenProtocol {
    var currencySymbol: String {
        "0c787a604cc2ec986455f289013fae122f7a808a23e07ca09e16a2b0"
    }

    var tokenName: String {
        "0014df1061647366"
    }

    var isVerified: Bool {
        true
    }

    var ticker: String {
        "Ticker"
    }

    var projectName: String {
        "Name"
    }

    var percentChange: Double {
        20.00
    }

    var priceValue: Double {
        0.000002
    }

    var subPriceValue: Double {
        10000
    }

    var category: [String] {
        ["DEX", "DeFi", "Smart contract", "Staking", "Staking", "Staking", "Staking"]
    }

    var socialLinks: [SocialLinks: String] {
        return [.coinGecko: ""]
    }
    var decimals: Int {
        2
    }

    var hasMetaData: Bool {
        true
    }

    init() {}
}


extension RiskCategory: @retroactive Identifiable {
    public var id: UUID {
        UUID()
    }

    var textColor: Color {
        switch self {
        case .a, .aa, .aaa:
            return Color.colorDecorativeLeafSub
        case .b, .bb, .bbb:
            return .colorDecorativeYellowSub
        case .c, .cc, .ccc:
            return .colorDecorativeCreamSub
        case .d:
            return .colorBaseTent
        }
    }

    var backgroundColor: Color {
        switch self {
        case .a, .aa, .aaa:
            return Color.colorDecorativeLeaf
        case .b, .bb, .bbb:
            return .colorDecorativeYellowDefault
        case .c, .cc, .ccc:
            return .colorDecorativeCream
        case .d:
            return .colorInteractiveDangerDefault
        }
    }
}

enum SocialLinks: String {
    case coinGecko
    case coinMarketCap
    case discord
    case telegram
    case twitter
    case website
    case cardanoscan
    case adaStat

    var image: ImageResource {
        switch self {
        case .coinGecko:
            return .icCoingecko
        case .coinMarketCap:
            return .icCoincap
        case .discord:
            return .icDiscord
        case .telegram:
            return .icTelegram
        case .twitter:
            return .icTwitter
        case .website:
            return .icWebsite
        case .cardanoscan:
            return .icCardanoscan
        case .adaStat:
            return .icAdaStat
        }
    }

    var order: Int {
        switch self {
        case .coinGecko:
            0
        case .coinMarketCap:
            1
        case .discord:
            2
        case .telegram:
            3
        case .twitter:
            4
        case .website:
            5
        case .cardanoscan:
            6
        case .adaStat:
            7
        }
    }
}

struct TokenDefault: TokenProtocol, Hashable, Then {
    var currencySymbol: String {
        symbol
    }

    var tokenName: String {
        tName
    }

    var isVerified: Bool { mIsVerified }

    var ticker: String { mTicker }

    var projectName: String { minName }

    var category: [String] { [] }

    var percentChange: Double { 0 }

    var priceValue: Double {
        netValue
    }

    var subPriceValue: Double {
        netSubValue
    }

    var socialLinks: [SocialLinks: String] { [:] }

    var decimals: Int { mDecimals }

    var symbol: String = ""
    var tName: String = ""
    var minName: String = ""
    var mTicker: String = ""
    var netValue: Double = 0
    var netSubValue: Double = 0
    var mDecimals: Int = 0
    var mIsVerified: Bool = false
    var amount: Double {
        netValue
    }

    var hasMetaData: Bool {
        true
    }

    init() {}

    init(
        symbol: String,
        tName: String,
        minName: String = "",
        netValue: Double = 0,
        netSubValue: Double = 0,
        decimal: Int = 0
    ) {
        self.symbol = symbol
        self.tName = tName
        self.minName = minName
        self.netValue = netValue
        self.netSubValue = netSubValue
        self.mDecimals = decimal
    }
}

extension TokenProtocol {
    private func isIPFSUrl(_ ipfs: String) -> Bool {
        return ipfs.hasPrefix(MinWalletConstant.IPFS_PREFIX)
    }

    private func buildIPFSFromUrl(_ ipfsUrl: String) -> String? {
        guard let data = ipfsUrl.components(separatedBy: MinWalletConstant.IPFS_PREFIX).last else {
            return nil
        }
        return MinWalletConstant.IPFS_GATEWAY + data
    }

    func buildNFTURL() -> String? {
        isIPFSUrl(nftImage) ? buildIPFSFromUrl(nftImage) : nil
    }

    var isAdaHandleName: Bool {
        currencySymbol == UserInfo.POLICY_ID
    }
}
