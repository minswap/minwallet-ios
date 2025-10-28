import Foundation
import Then
import SwiftUI


struct WrapOrderHistory: Then, Equatable, Identifiable {
    var id: String = ""
    var orders: [OrderHistory] = []

    //for load more
    var cursor: String? = nil

    //For UI
    var orderType: OrderHistory.OrderType = .swap

    var source: AggrSource?
    var protocolSource: AggregatorSource?
    var input: OrderHistory.InputOutput?
    var output: OrderHistory.InputOutput?
    var inputAsset: [OrderHistory.InputOutput] = []
    var outputAsset: [OrderHistory.InputOutput] = []
    var status: OrderV2Status = .batched
    var percent: Double = 0
    var heightSize: CGFloat = 170

    init(orders: [OrderHistory] = [], key: String = "") {
        id = key
        cursor = orders.last?.id
        self.orders = orders.sorted(by: {
            ($0.status?.number ?? 0) < ($1.status?.number ?? 0)
        })

        status = {
            guard orders.count > 1 else { return orders.first?.status ?? .created }
            if orders.allSatisfy({ $0.status == .cancelled }) {
                return .cancelled
            }
            return orders.first { $0.status == .created } != nil ? .created : .batched
        }()

        orderType = orders.first?.detail.orderType ?? .swap
        source = orders.first?.aggregatorSource
        protocolSource = orders.first?.protocolSource
        input = orders.first?.input
        output = orders.first?.output

        let inputs = Dictionary(grouping: orders.flatMap({ $0.inputAsset }), by: { $0.id })
        let outputs = Dictionary(grouping: orders.flatMap({ $0.outputAsset }), by: { $0.id })

        inputAsset = inputs.map({ (key, values) in
            let amount = values.map({ $0.amount }).reduce(0, +)
            let minimumAmount = values.map({ $0.minimumAmount }).reduce(0, +)
            return OrderHistory.InputOutput(asset: values.first?.asset, amount: amount, minimumAmount: minimumAmount, amountInDecimal: true)
        })
        outputAsset = outputs.map({ (key, values) in
            let amount = values.map({ $0.amount }).reduce(0, +)
            let minimumAmount = values.map({ $0.minimumAmount }).reduce(0, +)
            return OrderHistory.InputOutput(asset: values.first?.asset, amount: amount, minimumAmount: minimumAmount, amountInDecimal: true)
        })

        if orderType == .partialSwap && orders.count > 1 {
            let orderCompleted = orders.filter({ $0.status == .batched }).count
            percent = Double(orderCompleted) / Double(orders.count) * 100
        }

        let heightInputAsset = CGFloat(max(inputAsset.count * 20 + (inputAsset.count - 1) * 4, 36))
        let heightOutputAsset = status == .created ? 36 : CGFloat(max(outputAsset.count * 20 + (outputAsset.count - 1) * 4, 36))
        heightSize = max(170, 170 - 36 * 2 + heightInputAsset + heightOutputAsset)
    }
}
