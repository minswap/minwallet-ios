import Foundation
import Alamofire
import SwiftyJSON


protocol APIRouter: Alamofire.URLRequestConvertible {
    func baseUrl() -> String
    func headers() -> Alamofire.HTTPHeaders
    func path() -> String
    func method() -> Alamofire.HTTPMethod
    func parameters() -> Alamofire.Parameters
    func encoding() -> ParameterEncoding
    
    func domainAdapter() -> DomainAdapter?
    func domainHeadersContext() -> DomainHeadersContext?
    
    func domainAuthRetrier() -> GDomainAuthRetrier?
}

extension APIRouter {
    
    // MARK: default API
    var defaultEncoding: ParameterEncoding {
        (method() == .get)
            ? URLEncoding.default
            : JSONEncoding.default
    }
    
    var defaultFullURL: String {
        baseUrl().appending(path())
    }
    
    func defaultAsURLRequest() throws -> URLRequest {
        // URL, method, headers
        var urlRequest = try URLRequest(
            url: defaultFullURL,
            method: method(),
            headers: headers())
        
        // parameters
        do {
            let parameters = parameters()
            urlRequest = try encoding().encode(urlRequest, with: parameters)
        } catch {
            print("Encoding fail \(error.localizedDescription)")
        }
        
        return urlRequest
    }
    
    // MARK: adapted API
    var adaptedFullURL: String {
        if let adapter = domainAdapter(),
            !adapter.baseURLString.isEmpty,
            baseUrl().isEmpty
        {
            return adapter.baseURLString.appending(path())
        }
        
        return baseUrl().appending(path())
    }
    
    func adaptedHeaders() -> HTTPHeaders {
        if let adapter = domainAdapter() {
            return adapter.adaptHeaders(
                context: domainHeadersContext(),
                headers: headers())
        }
        
        return headers()
    }
    
    func adaptedAsURLRequest() throws -> URLRequest {
        var urlRequest: URLRequest = try asURLRequest()
        if let adapter = domainAdapter() {
            // url
            urlRequest.url = try adaptedFullURL.asURL()
            // headers
            let adptHeaders = adapter.adaptHeaders(
                context: domainHeadersContext(),
                headers: .init(urlRequest.allHTTPHeaderFields ?? [:]))
            for (_, header) in adptHeaders.enumerated() {
                urlRequest.setValue(header.value, forHTTPHeaderField: header.name)
            }
        }
        
        return urlRequest
    }
}

// MARK: - Helper
public
    struct APIRouterCommon
{
    static var logAPIDurationThreshold: TimeInterval? = nil
    static var onLogAPIDuration: ((_ response: AFDataResponse<Data>) -> Void)?
    
    static func parseDefaultErrorMessage(_ jsonData: JSON, alternateMessageIfEmptyError: String = APIRouterError.GenericError) throws {
        if jsonData["error"].exists() {
            let error = jsonData["error"].stringValue
            let message = jsonData["message"].string ?? error
            
            throw APIRouterError.serverError(message: message)
        }
        return
    }
}

extension Alamofire.AFDataResponse where Success == Data, Failure == AFError {
    @discardableResult
    func logAPIDuration() -> Self {
        guard let threshold = APIRouterCommon.logAPIDurationThreshold,
            let requestDuration = self.metrics?.taskInterval.duration,
            requestDuration >= threshold
        else { return self }
        
        APIRouterCommon.onLogAPIDuration?(self)
        
        return self
    }
}


// MARK: - Promise: async_request
extension APIRouter {
    func async_request(
        sessionManager: Session = Session.default,
        debugRequest: Bool = false,
        debugResponse: Bool = false
    ) async throws -> JSON {
        try await _async_requestWithRetry {
            await sessionManager
                .request(
                    adaptedFullURL,
                    method: method(),
                    parameters: parameters(),
                    encoding: encoding(),
                    headers: adaptedHeaders()
                )
                .debugLog(debugRequest)
                .serializingData().response
                .debugLog(debugResponse)
                .logAPIDuration()
        }
        .tryMap({ try JSON(data: $0) })
        .result.get()
    }
    
    func async_requestWithManualURLRequest(
        sessionManager: Session = Session.default,
        debugRequest: Bool = false,
        debugResponse: Bool = false
    ) async throws -> JSON {
        try await _async_requestWithRetry {
            await sessionManager
                .request(try adaptedAsURLRequest())
                .debugLog(debugRequest)
                .serializingData().response
                .debugLog(debugResponse)
                .logAPIDuration()
        }
        .tryMap({ try JSON(data: $0) })
        .result.get()
    }
    
    func async_uploadRequest(
        sessionManager: Session = Session.default,
        multipartFormData: @escaping (MultipartFormData) -> Void,
        updateProgress: ((Progress) -> Void)? = nil,
        debugRequest: Bool = false,
        debugResponse: Bool = false
    ) async throws -> JSON {
        try await _async_requestWithRetry {
            await sessionManager
                .upload(
                    multipartFormData: multipartFormData,
                    to: adaptedFullURL,
                    method: method(),
                    headers: adaptedHeaders()
                )
                .debugLog(debugRequest)
                .uploadProgress {
                    updateProgress?($0)
                }
                .serializingData().response
                .debugLog(debugResponse)
                .logAPIDuration()
        }
        .tryMap({ try JSON(data: $0) })
        .result.get()
    }
    
    func async_uploadRequestWithManualURLRequest(
        sessionManager: Session = Session.default,
        multipartFormData: @escaping (MultipartFormData) -> Void,
        debugRequest: Bool = false,
        debugResponse: Bool = false
    ) async throws -> JSON {
        try await _async_requestWithRetry {
            await sessionManager
                .upload(
                    multipartFormData: multipartFormData,
                    with: try adaptedAsURLRequest()
                )
                .debugLog(debugRequest)
                .serializingData().response
                .debugLog(debugResponse)
                .logAPIDuration()
        }
        .tryMap({ try JSON(data: $0) })
        .result.get()
    }
}
