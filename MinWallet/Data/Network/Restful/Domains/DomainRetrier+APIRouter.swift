import Foundation
import Alamofire
import Combine


// MARK: - Logic refresh token
extension APIRouter {
    func _async_requestWithRetry<T>(
        _ body: @escaping () async throws -> AFDataResponse<T>
    ) async throws -> AFDataResponse<T> {
        let response: AFDataResponse<T> = try await {
            if let authRetrier = domainAuthRetrier() {
                let refreshResult = authRetrier.shouldRefreshTokenIfRequired(endpoint: self)
                // require
                if refreshResult.requiresRefresh {
                    try await authRetrier.refresh()
                    let second = max(0.0, refreshResult.delay ?? 0.0)
                    try await Task.sleep(nanoseconds: UInt64(second * 1_000_000_000))
                    return try await body()
                }
            }
            // doesNotRequire
            return try await body()
        }()

        if let authRetrier = domainAuthRetrier() {
            let retryResult = try authRetrier.shouldRetryDueToAuthenticationError(
                endpoint: self,
                response: response.response,
                data: response.data
            )
            // retry
            if retryResult.retryRequired {
                try await authRetrier.refresh()
                let second = max(0.0, retryResult.delay ?? 0.0)
                try await Task.sleep(nanoseconds: UInt64(second * 1_000_000_000))
                return try await body()
                
            } else if let error = retryResult.error {
                throw error
            }
            // fallthrough ↓
        }
        
        // doNotRetry
        return response
    }
}
