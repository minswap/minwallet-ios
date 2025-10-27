import SwiftUI
import Then
import Combine


@MainActor
class ToWalletAddressViewModel: ObservableObject {
    
    @Published
    var adaAddress: AdaAddress?
    @Published
    var isChecking: Bool?
    @Published
    var address: String = ""
    @Published
    var errorType: ErrorType?
    
    let tokens: [WrapTokenSend]
    
    private var cancellables: Set<AnyCancellable> = []
    let isSendAll: Bool
    
    init(tokens: [WrapTokenSend], isSendAll: Bool) {
        self.tokens = tokens
        self.isSendAll = isSendAll
        $address
            .map({ $0.replacingOccurrences(of: " ", with: "") })
            .removeDuplicates()
            .debounce(for: .milliseconds(300), scheduler: DispatchQueue.main)
            .sink(receiveValue: { [weak self] newAddress in
                guard let self = self else { return }
                self.address = newAddress
                self.validateAddress(newAddress: newAddress)
            })
            .store(in: &cancellables)
    }
    
    func checkAddress() {
        guard case .handleNotResolved = errorType else { return }
        Task {
            isChecking = true
            await resolveAdaName()
            isChecking = false
        }
    }
    
    func reset() {
        errorType = nil
        isChecking = nil
        adaAddress = nil
        address = ""
    }
    
    private func validateAddress(newAddress: String) {
        errorType = nil
        guard !address.isEmpty else { return }
        guard address.count != 1
        else {
            errorType = .invalidAddress
            return
        }
        if address.starts(with: "$") {
            //Handle AdaName
            if address.isAdaHandleName {
                errorType = .handleNotResolved(adaName: address)
            } else {
                errorType = .invalidAdaName
            }
        } else {
            //Wallet address
            if !address.hasPrefix(MinWalletConstant.addressPrefix) {
                errorType = .invalidAddress
            } else {
                let suffixAddress = address.trimmingPrefix(MinWalletConstant.addressPrefix)
                if suffixAddress.count == 98 {
                    errorType = nil
                } else {
                    errorType = .invalidAddress
                }
            }
        }
    }
    
    private func resolveAdaName() async {
        do {
            let adaName = address.trimmingPrefix("$")
            guard let url = URL(string: MinWalletConstant.adaHandleURL + "/" + adaName)
            else {
                errorType = .handleResolvedError(msg: "Handle not found")
                return
            }
            
            let (data, _) = try await URLSession.shared.data(from: url)
            guard let jsonData = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [String: Any]
            else {
                errorType = .handleResolvedError(msg: "Handle not found")
                return
            }
            
            if let resolvedAddresses = jsonData["resolved_addresses"] as? [String: Any],
                let adaAddress = resolvedAddresses["ada"] as? String, !adaAddress.isEmpty
            {
                let name = (jsonData["name"] as? String) ?? String(adaName)
                self.adaAddress = .init()
                    .with({
                        $0.name = name
                        $0.address = adaAddress
                    })
                address = ""
                errorType = nil
            } else if let error = jsonData["message"] as? String {
                errorType = .handleResolvedError(msg: LocalizedStringKey(error))
            } else {
                errorType = .handleResolvedError(msg: "Handle not found")
            }
        } catch {
            errorType = .handleResolvedError(msg: LocalizedStringKey(error.localizedDescription))
        }
    }
}

struct AdaAddress: Then {
    var name: String = ""
    var address: String = ""
    //addr1 qxjd7yhl8d8aezz0spg4zghgtn7rx7zun7fkekrtk2zvw9vsxg93khf9crelj4wp6kkmyvarlrdvtq49akzc8g58w9cq5svq4r
    //addr_test1 qzwv9xmz46e8pe7tcpcvuz27r4yq9mzt6sa4eekvgyt4jr8gxzywkx4dpkcnnk6q3pqs422thw4u9fgjyq4slpzn3m6qmfwjev
    init() {}
}


extension ToWalletAddressViewModel {
    enum ErrorType {
        case invalidAddress
        case invalidAdaName
        case handleResolvedError(msg: LocalizedStringKey)
        case handleNotResolved(adaName: String)
        
        var errorDesc: LocalizedStringKey {
            switch self {
            case .invalidAddress:
                return "Invalid address"
            case let .handleResolvedError(msg):
                return msg
            case let .handleNotResolved(adaName):
                return "ADA Handle (\(adaName)): not resolved yet."
            case .invalidAdaName:
                return "Invalid handle. Only a-z, 0-9, dash (-), underscore (_), and period (.) are allowed."
            }
        }
    }
}
