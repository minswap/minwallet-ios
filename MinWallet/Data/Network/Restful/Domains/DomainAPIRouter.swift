import Foundation
import Alamofire


protocol DomainAPIRouter: APIRouter {}

extension DomainAPIRouter {
    // -- dùng domainAdapter
    func baseUrl() -> String { "" }
    func headers() -> HTTPHeaders { .init() }
    // -- dùng domainAdapter
    
    func encoding() -> ParameterEncoding { defaultEncoding }
    
    func asURLRequest() throws -> URLRequest { try defaultAsURLRequest() }
    
    // -- implement domainAdapter => trỏ tới domain phù hợp
    
    func domainHeadersContext() -> DomainHeadersContext? { nil }
    
    func domainAuthRetrier() -> GDomainAuthRetrier? { GDomainRefreshRetrierNoOpDefault.sharedAuthRetrier }
}
