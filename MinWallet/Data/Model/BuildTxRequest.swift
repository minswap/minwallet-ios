import Foundation
import ObjectMapper
import Then


struct BuildTxRequest: Then {
    var sender: String = ""
    var min_amount_out: String = ""
    var amount_in_decimal: Bool = false
    var estimate: Estimate = Estimate()

    init() {}
}

extension BuildTxRequest {
    struct Estimate: Then {
        var amount: String = ""
        var token_in: String = ""
        var token_out: String = ""
        var slippage: Double = 0
        var exclude_protocols: [AggregatorSource] = []
        var allow_multi_hops: Bool = true
        var partner: String = ""

        init() {}
    }
}
