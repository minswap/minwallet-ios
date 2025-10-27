import Foundation
import Alamofire


extension DomainAPIRouter {
    func domainAdapter() -> DomainAdapter? {
        MinWalletDomainAdapter.shared
    }
}

fileprivate class MinWalletDomainAdapter: DomainAdapter {
    
    static let shared = MinWalletDomainAdapter()
    
    private init() {}
    
    var baseURLString: String { MinWalletConstant.minAggURL }
    
    var accessToken: String { "" }
    
    private var defaultAdditionalHeaders: HTTPHeaders {
        var requestHeader = HTTPHeaders()
        
        if let text = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String {
            requestHeader["appVersion"] = text
        }
        
        return requestHeader
    }
    
    func adaptHeaders(context: DomainHeadersContext?, headers: HTTPHeaders) -> HTTPHeaders {
        var mergedHeaders = defaultAdditionalHeaders
        headers.forEach { mergedHeaders[$0.name] = $0.value }
        return mergedHeaders
    }
}
