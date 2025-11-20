import SwiftUI
import ObjectMapper

extension AppSetting {
    func getAdaPrice() {
        Task {
            repeat {
                let data = try? await MinWalletAPIRouter.getAdaPrice(currency: "usd").async_request()
                currencyInADA = Mapper<AdaPriceResponse>().map(JSON: data?.dictionaryObject ?? [:])?.value.price ?? 0
                try? await Task.sleep(for: .seconds(5 * 60))
            } while (!Task.isCancelled)
        }
    }
}
