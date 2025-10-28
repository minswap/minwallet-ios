import SwiftUI
import ObjectMapper
import MinWalletAPI
import Combine


@MainActor
class TokenDetailViewModel: ObservableObject {

    var chartPeriods: [ChartPeriod] = [.oneDay, .oneWeek, .oneMonth, .sixMonths, .oneYear, .all]

    @Published
    var token: TokenProtocol!
    @Published
    var topAsset: TopAssetsResponse.AssetMetric?
    @Published
    var riskCategory: RiskScoreOfAssetQuery.Data.RiskScoreOfAsset?
    @Published
    var chartPeriod: ChartPeriod = .oneDay
    @Published
    var chartDatas: [LineChartData] = []
    @Published
    var isFav: Bool = false
    @Published
    var scrollOffset: CGPoint = .zero
    @Published
    var sizeOfLargeHeader: CGSize = .zero
    @Published
    var selectedIndex: Int?
    @Published
    var isSuspiciousToken: Bool = false
    @Published
    var isLoadingPriceChart: Bool = true
    @Published
    var isInteracting = false

    var chartDataSelected: LineChartData? {
        guard let selectedIndex = selectedIndex, selectedIndex < chartDatas.count else { return chartDatas.last }
        return chartDatas[gk_safeIndex: selectedIndex]
    }

    var percent: Double {
        guard let selectedIndex = selectedIndex, !chartDatas.isEmpty else { return 0 }
        guard let current = chartDatas[gk_safeIndex: selectedIndex]?.value, let previous = chartDatas[gk_safeIndex: selectedIndex - 1]?.value else { return 0 }
        return (current - previous) / previous * 100
    }

    private var cancellables: Set<AnyCancellable> = []

    init(token: TokenProtocol = TokenProtocolDefault()) {
        self.token = token

        $chartPeriod
            .removeDuplicates()
            .sink { [weak self] newData in
                guard let self = self else { return }
                Task {
                    self.isLoadingPriceChart = true
                    self.chartPeriod = newData
                    self.selectedIndex = nil
                    self.chartDatas = []
                    try? await Task.sleep(for: .milliseconds(800))
                    await self.getPriceChart()
                    self.isLoadingPriceChart = false
                }
            }
            .store(in: &cancellables)

        isFav = UserInfo.shared.tokensFav.contains(where: { $0.uniqueID == token.uniqueID })

        getTokenDetail()
        getRickScore()
        checkTokenValid()
    }

    private func getTokenDetail() {
        Task {
            let jsonData = try await MinWalletAPIRouter.detailAsset(id: token.currencySymbol + token.tokenName).async_request()
            let asset = Mapper<TopAssetsResponse.AssetMetric>.init().map(JSON: jsonData.dictionaryObject ?? [:])
            self.topAsset = asset
        }
    }

    private func getPriceChart() async {
        let jsonData = try? await MinWalletAPIRouter.chartInfo(id: token.currencySymbol + token.tokenName, period: chartPeriod).async_request()
        let chartDatas = jsonData?.arrayValue
            .map({ priceChartJSON in
                let time = priceChartJSON["timestamp"].doubleValue / 1000
                let value = priceChartJSON["value"].doubleValue
                return LineChartData(date: Date(timeIntervalSince1970: time), value: value, type: .outside)
            })
        self.chartDatas = chartDatas ?? []
        self.selectedIndex = max(0, self.chartDatas.count - 1)
    }

    private func getRickScore() {
        Task {
            let riskScore = try? await MinWalletService.shared.fetch(query: RiskScoreOfAssetQuery(asset: InputAsset(currencySymbol: token.currencySymbol, tokenName: token.tokenName)))
            self.riskCategory = riskScore?.riskScoreOfAsset
        }
    }

    private func checkTokenValid() {
        Task {
            isSuspiciousToken = await AppSetting.shared.isSuspiciousToken(currencySymbol: token.currencySymbol)
        }
    }

    func formatDate(value: Date) -> String {
        guard !chartDatas.isEmpty else { return " " }
        let inputFormatter = DateFormatter()
        switch chartPeriod {
        case .oneDay:
            inputFormatter.dateFormat = "HH:mm"
        case .oneMonth:
            inputFormatter.dateFormat = "MMM dd"
        case .oneWeek:
            inputFormatter.dateFormat = "MMM dd"
        case .oneYear:
            inputFormatter.dateFormat = "MMM yyyy"
        case .sixMonths:
            inputFormatter.dateFormat = "MMM dd"
        case .all:
            inputFormatter.dateFormat = "MMM dd yyyy"
        }
        inputFormatter.locale = Locale(identifier: "en_US_POSIX")
        return inputFormatter.string(from: value)
    }

    func formatDateAnnotation(value: Date) -> String {
        guard !chartDatas.isEmpty else { return " " }
        let inputFormatter = DateFormatter()
        switch chartPeriod {
        case .oneDay:
            inputFormatter.dateFormat = "HH:mm"
        case .oneMonth:
            inputFormatter.dateFormat = "HH:mm, MMM dd"
        case .oneWeek:
            inputFormatter.dateFormat = "HH:mm, MMM dd"
        case .oneYear:
            inputFormatter.dateFormat = "MMM dd, yyyy"
        case .sixMonths:
            inputFormatter.dateFormat = "HH:mm, MMM dd"
        case .all:
            inputFormatter.dateFormat = "MMM dd yyyy"
        }
        inputFormatter.locale = Locale(identifier: "en_US_POSIX")
        return inputFormatter.string(from: value)
    }
}
