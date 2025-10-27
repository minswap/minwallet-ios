import SwiftUI
import ObjectMapper
import Then
import Combine


@MainActor
class SearchTokenViewModel: ObservableObject {
    @Published
    var tokens: [TopAssetsResponse.AssetMetric] = []
    @Published
    var tokensFav: [TokenProtocol] = []
    @Published
    var isDeleted: [Bool] = []
    @Published
    var offsets: [CGFloat] = []
    @Published
    var keyword: String = ""
    @Published
    var recentSearch: [String] = []
    
    private var input: TopAssetsInput = .init()
    private var searchAfter: [Any]? = nil
    private var hasLoadMore: Bool = true
    private let limit: Int = 20
    private var isFetching: Bool = true
    
    private var cancellables: Set<AnyCancellable> = []
    
    @Published
    var showSkeleton: Bool = true
    
    init() {
        $keyword
            .removeDuplicates()
            .dropFirst()
            .debounce(for: .milliseconds(500), scheduler: DispatchQueue.main)
            .sink { [weak self] newData in
                guard let self = self else { return }
                self.keyword = newData
                self.getTokens()
            }
            .store(in: &cancellables)
        $keyword
            .removeDuplicates()
            .dropFirst()
            .sink { [weak self] newData in
                self?.showSkeleton = true
            }
            .store(in: &cancellables)
        
        recentSearch = UserDataManager.shared.tokenRecentSearch
    }
    
    func getTokens(isLoadMore: Bool = false) {
        showSkeleton = !isLoadMore
        isFetching = true
        input = TopAssetsInput()
            .with({
                if let searchAfter = searchAfter, isLoadMore {
                    $0.search_after = searchAfter
                } else {
                    $0.search_after = nil
                }
                if !keyword.isBlank {
                    $0.term = keyword.trimmingCharacters(in: .whitespacesAndNewlines)
                } else {
                    $0.term = nil
                }
                $0.limit = limit
                $0.sort_field = .volume_usd_24h
                $0.sort_direction = .desc
            })
        
        Task {
            if keyword.isBlank {
                self.tokensFav = await self.getTokenFav()
                self.isDeleted = self.tokensFav.map({ _ in false })
                self.offsets = self.tokensFav.map({ _ in 0 })
            } else {
                self.tokensFav = []
                self.isDeleted = []
                self.offsets = []
            }
            
            let jsonData = try? await MinWalletAPIRouter.topAssets(input: input).async_request()
            let tokens = Mapper<TopAssetsResponse>.init().map(JSON: jsonData?.dictionaryObject ?? [:])
            let _tokens = tokens?.assets ?? []
            if isLoadMore {
                self.tokens += _tokens
            } else {
                self.tokens = _tokens
            }
            self.searchAfter = tokens?.search_after
            self.hasLoadMore = _tokens.count >= self.limit || self.searchAfter != nil
            self.showSkeleton = false
            self.isFetching = false
        }
    }
    
    func loadMoreData(item: TopAssetsResponse.AssetMetric) {
        guard hasLoadMore, !isFetching, !keyword.isBlank else { return }
        let thresholdIndex = tokens.index(tokens.endIndex, offsetBy: -2)
        if tokens.firstIndex(where: { ($0.asset.currencySymbol + $0.asset.tokenName) == (item.asset.currencySymbol + $0.asset.tokenName) }) == thresholdIndex {
            getTokens(isLoadMore: true)
        }
    }
    
    func clearRecentSearch() {
        recentSearch = []
        UserDataManager.shared.tokenRecentSearch = []
    }
    
    func addRecentSearch(keyword: String) {
        var recentSearch = recentSearch
        recentSearch.insert(keyword.trimmingCharacters(in: .whitespacesAndNewlines), at: 0)
        recentSearch = Set(recentSearch.reversed()).map({ $0 })
        self.recentSearch = recentSearch.reversed()
        UserDataManager.shared.tokenRecentSearch = self.recentSearch
    }
    
    func deleteTokenFav(at index: Int) {
        guard let item = tokensFav[gk_safeIndex: index] else { return }
        let tokensFav = tokensFav.filter { $0.uniqueID != item.uniqueID }
        self.tokensFav = tokensFav
        self.isDeleted = self.tokensFav.map({ _ in false })
        self.offsets = self.tokensFav.map({ _ in 0 })
        UserInfo.shared.tokenFavSelected(token: item, isAdd: false)
    }
    
    private func getTokenFav() async -> [TokenProtocol] {
        await MarketViewModel.getTopAssetsFav()
    }
}
