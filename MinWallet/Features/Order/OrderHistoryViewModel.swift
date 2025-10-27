import SwiftUI
import Combine
import SwiftyJSON
import ObjectMapper
import Then


@MainActor
class OrderHistoryViewModel: ObservableObject {
    @Published
    var showSearch: Bool = false
    @Published
    var showFilterView: Bool = false
    @Published
    var showCancelOrder: Bool = false
    @Published
    var keyword: String = ""
    @Published
    var wrapOrders: [WrapOrderHistory] = []
    @Published
    var showSkeleton: Bool = true
    @Published
    var isDeleted: [Bool] = []
    @Published
    var offsets: [CGFloat] = []
    
    private var cancellables: Set<AnyCancellable> = []
    
    @Published
    var filterSourceSelected: AggrSource?
    @Published
    var statusSelected: OrderV2Status?
    @Published
    var orderType: OrderHistory.OrderType?
    @Published
    var source: AggregatorSource?
    @Published
    var fromDate: Date?
    @Published
    var toDate: Date?
    
    private var pagination: Pagination = .init()
    
    @Published
    var orderCancelSelected: [String: OrderHistory] = [:]
    @Published
    var orderCancelCanSelect: [String: OrderHistory] = [:]
    @Published
    var showCancelOrderList: Bool = false
    @Published
    var orderCancel: WrapOrderHistory?
    
    private var rawOrders: [OrderHistory] = []
    
    var hasOnlyOneOrderCancel: Bool {
        guard let orderCancel = orderCancel else { return false }
        return orderCancel.orders.count == 1 && orderCancel.orders.first?.status == .created
    }
    
    var countFilter: Int {
        [
            (fromDate != nil || toDate != nil) ? true : nil,
            filterSourceSelected,
            statusSelected,
            orderType,
            source,
        ]
        .compactMap { $0 }
        .count
    }
    
    init() {
        $keyword
            .removeDuplicates()
            .debounce(
                for: .milliseconds(400),
                scheduler: DispatchQueue.main
            )
            .sink(receiveValue: { [weak self] value in
                guard let self = self else { return }
                Task {
                    self.keyword = value
                    await self.fetchData()
                }
            })
            .store(in: &cancellables)
    }
    
    func fetchData(showSkeleton: Bool = true, fromPullToRefresh: Bool = false) async {
        //        withAnimation {
        self.showSkeleton = showSkeleton
        //        }
        if fromPullToRefresh {
            try? await Task.sleep(for: .seconds(1))
        }
        pagination = Pagination()
            .with({
                $0.isFetching = true
            })
        let rawOrders = await getOrderHistory()
        let cursorID = rawOrders.last?.id ?? ""
        pagination = pagination.with({
            $0.isFetching = false
            //$0.hasMore = orders.count >= pagination.limit
            $0.hasMore = !rawOrders.isEmpty
            $0.cursor = cursorID.isEmpty ? nil : Int(cursorID)
        })
        
        self.rawOrders = rawOrders
        self.wrapOrders = groupOrders(rawOrders)
        self.isDeleted = self.wrapOrders.map({ _ in false })
        self.offsets = self.wrapOrders.map({ _ in 0 })
        
        withAnimation {
            self.showSkeleton = false
        }
    }
    
    func loadMoreData(order: WrapOrderHistory) {
        guard pagination.readyToLoadMore else { return }
        let thresholdIndex = wrapOrders.index(wrapOrders.endIndex, offsetBy: -5)
        if wrapOrders.firstIndex(where: { $0.id == order.id }) == thresholdIndex {
            Task {
                pagination = pagination.with({ $0.isFetching = true })
                let _orders = await getOrderHistory()
                
                self.rawOrders += _orders
                let cursorID = _orders.last?.id ?? ""
                pagination = pagination.with({
                    $0.isFetching = false
                    //$0.hasMore = _orders.count >= pagination.limit
                    $0.hasMore = !_orders.isEmpty
                    $0.cursor = cursorID.isEmpty ? nil : Int(cursorID)
                })
                
                self.wrapOrders = groupOrders(rawOrders)
                self.isDeleted = self.wrapOrders.map({ _ in false })
                self.offsets = self.wrapOrders.map({ _ in 0 })
            }
        }
    }
    
    var input: OrderHistory.Request {
        let address = UserInfo.shared.minWallet?.address ?? ""
        let keyword = keyword.trimmingCharacters(in: .whitespacesAndNewlines)
        let isTxID = keyword.count == 64
        return OrderHistory.Request()
            .with({
                $0.ownerAddress = address
                $0.txId = !keyword.isBlank && isTxID ? keyword : nil
                $0.token = !keyword.isBlank && !isTxID ? keyword : nil
                $0.fromTime = fromDate != nil ? String(Int(fromDate!.timeIntervalSince1970 * 1000)) : nil
                $0.status = statusSelected
                $0.filterSource = filterSourceSelected
                $0.source = source
                $0.type = orderType
                $0.toTime = toDate != nil ? String(toDate!.timeIntervalSince1970 * 1000 - 1) : nil
                $0.limit = pagination.limit
                $0.cursor = pagination.cursor
            })
    }
    
    func cancelOrder() async throws -> String? {
        let orders: [OrderHistory] = hasOnlyOneOrderCancel ? (orderCancel?.orders ?? []) : orderCancelSelected.map({ _, value in value })
        let jsonData = try await OrderAPIRouter.cancelOrder(address: UserInfo.shared.minWallet?.address ?? "", orders: orders).async_request()
        try APIRouterCommon.parseDefaultErrorMessage(jsonData)
        guard let txRaw = jsonData["cbor"].string, !txRaw.isEmpty else { throw AppGeneralError.localErrorLocalized(message: "Transaction not found") }
        let finalID = try await TokenManager.finalizeAndSubmitV2(txRaw: txRaw)
        await fetchData(showSkeleton: false)
        orderCancelSelected = [:]
        orderCancel = nil
        return finalID
    }
}

extension OrderHistory.Request {
    var fromDateTimeInterval: Date? {
        guard let fromDate = fromTime, !fromDate.isEmpty else { return nil }
        let fromDateTime = (Double(fromDate) ?? 0) / 1000
        return fromDateTime > 0 ? Date(timeIntervalSince1970: fromDateTime) : nil
    }
    
    var toDateTimeInterval: Date? {
        guard let toDate = toTime, !toDate.isEmpty else { return nil }
        let toDateTime = (Double(toDate) ?? 0) / 1000
        return toDateTime > 0 ? Date(timeIntervalSince1970: toDateTime) : nil
    }
}

extension OrderHistoryViewModel {
    private func getOrderHistory() async -> [OrderHistory] {
        do {
            let jsonData = try await OrderAPIRouter.getOrders(request: input).async_request()
            let orders = Mapper<OrderHistory>().gk_mapArrayOrNull(JSONObject: JSON(jsonData)["orders"].arrayObject ?? [:]) ?? []
            return orders
        } catch {
            return []
        }
    }
}
extension OrderHistoryViewModel {
    struct Pagination: Then {
        var cursor: Int?
        var limit: Int = 20
        var hasMore: Bool = true
        var isFetching: Bool = false
        
        var readyToLoadMore: Bool {
            return !isFetching && hasMore
        }
        init() {}
        
        mutating func reset() {
            isFetching = false
            hasMore = true
            cursor = nil
        }
    }
}


extension OrderHistoryViewModel {
    static func getOrders(orders: [OrderHistory]) async -> [OrderHistory] {
        let tokens = await withTaskGroup(of: OrderHistory?.self) { taskGroup in
            var results: [OrderHistory?] = []
            
            for item in orders {
                taskGroup.addTask {
                    await OrderHistoryViewModel.fetchOrder(by: item)
                }
            }
            
            for await result in taskGroup {
                results.append(result)
            }
            
            return results
        }
        return tokens.compactMap { $0 }
    }
    
    private static func fetchOrder(by order: OrderHistory) async -> OrderHistory? {
        let input = OrderHistory.Request()
            .with {
                $0.ownerAddress = UserInfo.shared.minWallet?.address ?? ""
                $0.txId = order.createdTxId
            }
        
        do {
            let jsonData = try await OrderAPIRouter.getOrders(request: input).async_request()
            let orders = Mapper<OrderHistory>().gk_mapArrayOrNull(JSONObject: JSON(jsonData)["orders"].arrayValue)
            return orders?.first { $0.id == order.id } ?? order
        } catch {
            return order
        }
    }
}


extension OrderHistoryViewModel {
    private func groupOrders(_ orders: [OrderHistory]) -> [WrapOrderHistory] {
        var groups: [(key: String, values: [OrderHistory])] = []
        var seenKeys: Set<String> = []
        
        for item in orders {
            if let index = groups.firstIndex(where: { $0.key == item.keyToGroup }) {
                groups[index].values.append(item)
            } else {
                groups.append((key: item.keyToGroup, values: [item]))
                seenKeys.insert(item.keyToGroup)
            }
        }
        
        return groups.map { (key: String, values: [OrderHistory]) in
            WrapOrderHistory(orders: values, key: key)
        }
    }
}
