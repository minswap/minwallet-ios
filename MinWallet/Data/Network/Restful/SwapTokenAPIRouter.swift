import Foundation
import Alamofire


enum SwapTokenAPIRouter: DomainAPIRouter {
    case estimate(request: EstimationRequest)
    case buildTX(request: BuildTxRequest)
    case signTX(cbor: String, witness_set: String)
    
    func path() -> String {
        switch self {
        case .estimate:
            return "/aggregator/estimate"
        case .buildTX:
            return "/aggregator/build-tx"
        case .signTX:
            return "/aggregator/finalize-and-submit-tx"
        }
    }
    
    func method() -> HTTPMethod {
        return .post
    }
    
    func parameters() -> Parameters {
        var params = Parameters()
        
        switch self {
        case let .estimate(req):
            params["amount"] = req.amount
            params["token_in"] = req.token_in
            params["token_out"] = req.token_out
            params["slippage"] = NSDecimalNumber(value: req.slippage)
            params["exclude_protocols"] = req.exclude_protocols.map({ $0.rawId })
            params["allow_multi_hops"] = true
            params["partner"] = ""
            params["amount_in_decimal"] = req.amount_in_decimal

        case let .buildTX(req):
            var estimateJSON = Parameters()
            estimateJSON["amount"] = req.estimate.amount
            estimateJSON["token_in"] = req.estimate.token_in
            estimateJSON["token_out"] = req.estimate.token_out
            estimateJSON["slippage"] = NSDecimalNumber(value: req.estimate.slippage)
            estimateJSON["exclude_protocols"] = req.estimate.exclude_protocols.map({ $0.rawId })
            estimateJSON["allow_multi_hops"] = true
            estimateJSON["partner"] = req.estimate.partner
            
            params["sender"] = req.sender
            params["min_amount_out"] = req.min_amount_out
            params["amount_in_decimal"] = req.amount_in_decimal
            params["estimate"] = estimateJSON

        case .signTX(let cbor, let witness_set):
            params["cbor"] = cbor
            params["witness_set"] = witness_set
        }
        return params
    }
}
