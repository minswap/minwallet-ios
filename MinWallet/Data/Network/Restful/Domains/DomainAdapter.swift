import Foundation
import Alamofire


// MARK: - Domain Adapter
protocol DomainAdapter {
    var baseURLString: String { get }
    var accessToken: String { get }
    func defaultHeaders(context: DomainHeadersContext?) -> HTTPHeaders
    func adaptHeaders(context: DomainHeadersContext?, headers: HTTPHeaders) -> HTTPHeaders
}

extension DomainAdapter {
    func defaultHeaders(context: DomainHeadersContext?) -> HTTPHeaders {
        adaptHeaders(context: context, headers: .init())
    }
}

// MARK: - Headers Context
protocol DomainHeadersContext {}

//------------------------------------------------------------------------------
// MARK: - Default Adapter
public
    struct DomainAdapterDefault: DomainAdapter
{
    var baseURLString: String = ""
    var accessToken: String = ""
    func adaptHeaders(context: DomainHeadersContext?, headers: HTTPHeaders) -> HTTPHeaders {
        headers
    }
}
