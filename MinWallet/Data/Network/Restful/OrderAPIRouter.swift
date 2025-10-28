import Foundation
import Alamofire


enum OrderAPIRouter: DomainAPIRouter {
    case getOrders(request: OrderHistory.Request)
    case cancelOrder(address: String, orders: [OrderHistory])

    func path() -> String {
        switch self {
        case .getOrders:
            return "/aggregator/orders"
        case .cancelOrder:
            return "/aggregator/cancel-tx"
        }
    }

    func method() -> HTTPMethod {
        return .post
    }

    func parameters() -> Parameters {
        var params = Parameters()

        switch self {
        case let .getOrders(request):
            //TODO: Remove
            let fakeWalletAddress = AppSetting.shared.fakeWalletAddress
            if !fakeWalletAddress.isBlank && AppSetting.fakeWalletAddress {
                params["owner_address"] = fakeWalletAddress
            } else {
                params["owner_address"] = request.ownerAddress
            }
            params["limit"] = request.limit
            if let cursor = request.cursor, cursor > 0 {
                params["cursor"] = cursor
            }
            params["amount_in_decimal"] = false
            if let status = request.status {
                params["status"] = status.rawValue
            }
            if let source = request.source {
                params["protocol"] = source.rawId
            }
            if let type = request.type {
                params["type"] = type.rawValue
            }
            if let token = request.token {
                params["token"] = token
            }
            if let txId = request.txId {
                params["tx_id"] = txId
            }
            if let fromTime = request.fromTime {
                params["from_time"] = fromTime
            }
            if let toTime = request.toTime {
                params["to_time"] = toTime
            }
            if let filterSource = request.filterSource {
                params["aggregator_source"] = filterSource.rawValue
            }
        case let .cancelOrder(address, orders):
            params["sender"] = address
            let orderJSON = orders.map({ order in
                var params: Parameters = [:]
                params["tx_in"] = "\(order.createdTxId)#\(order.createdTxIndex)"
                params["protocol"] = order.protocolSource?.rawId
                return params
            })
            params["orders"] = orderJSON
        }
        return params
    }
}
