import SwiftUI


struct SwapTokenSetting {
    var safeMode: Bool = true
    var autoRouter: Bool = true
    var slippageTolerance: String = ""
    var slippageSelected: SwapTokenSettingView.Slippage? = ._01
    var excludedPools: [AggregatorSource] = []
    
    init() {}
    
    func slippageSelectedValue() -> Double {
        guard let slippageSelected = slippageSelected
        else {
            return slippageTolerance.doubleValue
        }
        
        return slippageSelected.rawValue
    }
}
