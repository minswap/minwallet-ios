import Foundation


enum ChartPeriod: String {
    case oneDay = "1d"
    case oneMonth = "1M"
    case oneWeek = "1w"
    case oneYear = "1y"
    case sixMonths = "6M"
    case all = "all"
}

extension ChartPeriod: Identifiable {
    public var id: UUID {
        UUID()
    }
    
    var title: String {
        switch self {
        case .oneDay:
            "1D"
        case .oneMonth:
            "1M"
        case .oneWeek:
            "1W"
        case .oneYear:
            "1Y"
        case .sixMonths:
            "6M"
        case .all:
            "All"
        }
    }
}
