import SwiftUI
import Then
import MinWalletAPI
import SwiftyJSON


typealias ContractType = AMMType

extension OrderHistory.OrderType: Identifiable {
    public var id: String { UUID().uuidString }
    
    var title: LocalizedStringKey {
        switch self {
        case .deposit:
            "Deposit"
        case .donation:
            "Donation"
        case .limit:
            "Limit"
        case .swap:
            "Market"
        case .oco:
            "OCO"
        case .partialSwap:
            "Partial Fill"
        case .stopLoss:
            "Stop"
        case .withdraw:
            "Withdraw"
        case .zapIn:
            "Zap In"
        case .zapOut:
            "Zap Out"
        }
    }
    
    var titleFilter: LocalizedStringKey {
        switch self {
        case .deposit:
            "Deposit"
        case .limit:
            "Limit"
        case .swap:
            "Market"
        case .oco:
            "OCO"
        case .partialSwap:
            "Partial Fill"
        case .stopLoss:
            "Stop"
        case .withdraw:
            "Withdraw"
        case .zapIn:
            "Zap In"
        case .zapOut:
            "Zap Out"
        default:
            ""
        }
    }
    
    public init?(title: String) {
        switch title {
        case OrderHistory.OrderType.deposit.titleFilter.toString():
            self = .deposit
        case OrderHistory.OrderType.limit.titleFilter.toString():
            self = .limit
        case OrderHistory.OrderType.swap.titleFilter.toString():
            self = .swap
        case OrderHistory.OrderType.oco.titleFilter.toString():
            self = .oco
        case OrderHistory.OrderType.partialSwap.titleFilter.toString():
            self = .partialSwap
        case OrderHistory.OrderType.stopLoss.titleFilter.toString():
            self = .stopLoss
        case OrderHistory.OrderType.withdraw.titleFilter.toString():
            self = .withdraw
        case OrderHistory.OrderType.zapIn.titleFilter.toString():
            self = .zapIn
        case OrderHistory.OrderType.zapOut.titleFilter.toString():
            self = .zapOut
        default:
            self = .deposit
        }
    }
}

enum OrderV2Status: String, CaseIterable {
    case batched = "BATCHED"
    case cancelled = "CANCELLED"
    case created = "CREATED"
}

extension OrderV2Status: Identifiable {
    public var id: String { UUID().uuidString }
    
    var title: LocalizedStringKey {
        switch self {
        case .batched:
            "Completed"
        case .cancelled:
            "Cancelled"
        case .created:
            "Pending"
        }
    }
    
    var foregroundColor: Color {
        switch self {
        case .batched:
            .colorInteractiveToneSuccess
        case .cancelled:
            .colorInteractiveToneDanger
        case .created:
            .colorInteractiveToneWarning
        }
    }
    
    var foregroundCircleColor: Color {
        switch self {
        case .batched:
            .colorInteractiveToneSuccessSub
        case .cancelled:
            .colorInteractiveToneDangerSub
        case .created:
            .colorInteractiveToneWarningSub
        }
    }
    
    var backgroundColor: Color {
        switch self {
        case .batched:
            .colorSurfaceSuccess
        case .cancelled:
            .colorSurfaceDanger
        case .created:
            .colorSurfaceWarningDefault
        }
    }
    
    var number: Int {
        switch self {
        case .batched:
            2
        case .cancelled:
            3
        case .created:
            1
        }
    }
    
    public init?(title: String) {
        switch title {
        case OrderV2Status.created.title.toString():
            self = .created
        case OrderV2Status.cancelled.title.toString():
            self = .cancelled
        case OrderV2Status.batched.title.toString():
            self = .batched
        default:
            self = .batched
        }
    }
}

extension ContractType: @retroactive Identifiable {
    public var id: String { UUID().uuidString }
    
    var title: LocalizedStringKey {
        switch self {
        case .dex:
            "V1"
        case .dexV2:
            "V2"
        case .stableswap:
            "Stableswap"
        }
    }
    
    var backgroundColor: Color {
        switch self {
        case .dex:
            .colorDecorativeYellowDefault
        case .dexV2:
            .colorBrandRiver
        case .stableswap:
            .colorDecorativeLeaf
        }
    }
    
    var foregroundColor: Color {
        switch self {
        case .dex:
            .colorDecorativeYellowSub
        case .dexV2:
            .colorDecorativeBrandSub
        case .stableswap:
            .colorDecorativeLeafSub
        }
    }
}

extension AttributedString {
    //paragraphXSemiSmall
    func build(font: Font = .paragraphXSmall, color: Color = .colorInteractiveToneWarning) -> AttributedString {
        var attribute = self
        attribute.font = font
        attribute.foregroundColor = color
        return attribute
    }
}

extension AttributedString {
    init(key: LocalizedStringKey) {
        self.init(key.toString())
    }
}
