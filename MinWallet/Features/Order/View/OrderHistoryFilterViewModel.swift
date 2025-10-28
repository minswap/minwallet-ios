import Foundation


@MainActor
class OrderHistoryFilterViewModel: ObservableObject {
    @Published
    var filterSourceSelected: AggrSource?
    @Published
    var protocolSelected: AggregatorSource?
    @Published
    var statusSelected: OrderV2Status?
    @Published
    var actionSelected: OrderHistory.OrderType?
    @Published
    var fromDate: Date?
    @Published
    var toDate: Date?
    @Published
    var showSelectFromDate: Bool = false
    @Published
    var showSelectToDate: Bool = false

    init() {}

    func bindData(vm: OrderHistoryViewModel) {
        let input = vm.input
        filterSourceSelected = input.filterSource
        statusSelected = input.status
        actionSelected = input.type
        protocolSelected = input.source
        fromDate = input.fromDateTimeInterval
        toDate = input.toDateTimeInterval
    }
}
