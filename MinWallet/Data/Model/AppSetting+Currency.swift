import SwiftUI
import Combine
import MinWalletAPI


extension AppSetting {
    func getAdaPrice() {
        Task {
            repeat {
                let data = try? await MinWalletService.shared.fetch(query: AdaPriceQuery(currency: .case(.usd)))
                currencyInADA = data?.adaPrice.value?.price ?? 0
                try? await Task.sleep(for: .seconds(5 * 60))
            } while (!Task.isCancelled)
        }
    }
}
