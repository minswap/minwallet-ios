import Foundation
import Alamofire
import Combine


// MARK: - Domain Token Refresher
protocol GDomainTokenRefresher {
    var refreshToken: String { get }
    func shouldRefreshTokenIfRequired(endpoint: APIRouter) -> RequiresRefreshResult
    func requestRefreshToken() async throws
    func requestRefreshToken() -> AnyPublisher<Void, Error>
}

extension GDomainTokenRefresher {
    func shouldRefreshTokenIfRequired(endpoint: APIRouter) -> RequiresRefreshResult {
        return .doesNotRequireRefresh
    }
}


// MARK: - Domain Retrier
protocol GDomainRetrier {
    func shouldRetry(endpoint: APIRouter, response: HTTPURLResponse?, data: Data?) throws -> RetryResult
}


//------------------------------------------------------------------------------
// MARK: - Domain Authentication Retrier (refresh token)
class GDomainAuthRetrier {
    private var refreshTask: Task<Void, Error>?

    let refreshTokenRetryCountMax: Int
    let refreshTokenRetryDelay: DispatchTimeInterval
    private(set)
        var refreshWindow: RefreshWindow?
    var refreshTimestamps: [TimeInterval] = []

    let domainRefreshRetrier: GDomainRetrier & GDomainTokenRefresher

    init(
        domainRefreshRetrier: GDomainRetrier & GDomainTokenRefresher,
        refreshTokenRetryCountMax: Int = 3,
        refreshTokenRetryDelay: DispatchTimeInterval = .milliseconds(250),
        refreshWindow: RefreshWindow? = RefreshWindow()
    ) {
        self.domainRefreshRetrier = domainRefreshRetrier
        self.refreshTokenRetryCountMax = refreshTokenRetryCountMax
        self.refreshTokenRetryDelay = refreshTokenRetryDelay
        self.refreshWindow = refreshWindow
    }

    func shouldRefreshTokenIfRequired(endpoint: APIRouter) -> RequiresRefreshResult {
        domainRefreshRetrier.shouldRefreshTokenIfRequired(endpoint: endpoint)
    }

    func shouldRetryDueToAuthenticationError(endpoint: APIRouter, response: HTTPURLResponse?, data: Data?) throws -> RetryResult {
        let retryResult = try domainRefreshRetrier.shouldRetry(endpoint: endpoint, response: response, data: data)
        if retryResult.retryRequired, domainRefreshRetrier.refreshToken.isEmpty { return .doNotRetry }
        return retryResult
    }

    func refresh() async throws -> Void {
        return try await _refresh()
    }

    func _refresh() async throws -> Void {
        guard !isRefreshExcessive() else {
            throw APIRouterError.excessiveRefresh
        }

        if let refreshTask = refreshTask {
            return try await refreshTask.value
        }

        let task = Task { () throws -> Void in
            defer { refreshTask = nil }

            refreshTimestamps.append(ProcessInfo.processInfo.systemUptime)
            try await attempts(maximumRetryCount: refreshTokenRetryCountMax, delayBeforeRetry: refreshTokenRetryDelay) {
                try await self.domainRefreshRetrier.requestRefreshToken()
            }
        }

        self.refreshTask = task

        return try await task.value
    }

    func isRefreshExcessive() -> Bool {
        guard let refreshWindow = self.refreshWindow else { return false }

        let refreshWindowMin = ProcessInfo.processInfo.systemUptime - refreshWindow.interval

        refreshTimestamps = refreshTimestamps.filter({ refreshWindowMin <= $0 })
        let refreshAttemptsWithinWindow: Int = refreshTimestamps.count

        let isRefreshExcessive = refreshAttemptsWithinWindow >= refreshWindow.maximumAttempts

        return isRefreshExcessive
    }
}

//------------------------------------------------------------------------------
// MARK: - Default RefreshRetrier NoOp
class GDomainRefreshRetrierNoOpDefault: GDomainRetrier, GDomainTokenRefresher {

    static var sharedAuthRetrier = GDomainAuthRetrier(domainRefreshRetrier: GDomainRefreshRetrierNoOpDefault())

    func shouldRetry(endpoint: APIRouter, response: HTTPURLResponse?, data: Data?) throws -> RetryResult {
        guard let response = response,
            response.statusCode == 401  // 403?
        else { return .doNotRetry }
        return .doNotRetryWithError(APIRouterError.serverUnauthenticated)
    }

    var refreshToken: String {
        ""
    }

    func requestRefreshToken() async throws {
        throw APIRouterError.localError(message: APIRouterError.GenericError)
    }

    func requestRefreshToken() -> AnyPublisher<Void, Error> {
        Fail<Void, Error>(error: APIRouterError.localError(message: "Token refresh not implemented"))
            .eraseToAnyPublisher()
    }
}


//------------------------------------------------------------------------------
// MARK: - Helper Types
enum RequiresRefreshResult {
    /// Retry should be attempted immediately.
    case requiresRefresh
    /// Retry should be attempted after the associated `TimeInterval`.
    case requiresRefreshThenDelay(TimeInterval)
    /// Do not retry.
    case doesNotRequireRefresh
}

extension RequiresRefreshResult {
    var requiresRefresh: Bool {
        switch self {
        case .requiresRefresh, .requiresRefreshThenDelay: return true
        default: return false
        }
    }

    var delay: TimeInterval? {
        switch self {
        case let .requiresRefreshThenDelay(delay): return delay
        default: return nil
        }
    }
}


//------------------------------------------------------------------------------
// MARK: - Alamofire 5.6.1
extension RetryResult {
    var retryRequired: Bool {
        switch self {
        case .retry, .retryWithDelay: return true
        default: return false
        }
    }

    var delay: TimeInterval? {
        switch self {
        case let .retryWithDelay(delay): return delay
        default: return nil
        }
    }

    var error: Error? {
        guard case let .doNotRetryWithError(error) = self else { return nil }
        return error
    }
}

/// Type that defines a time window used to identify excessive refresh calls. When enabled, prior to executing a
/// refresh, the `AuthenticationInterceptor` compares the timestamp history of previous refresh calls against the
/// `RefreshWindow`. If more refreshes have occurred within the refresh window than allowed, the refresh is
/// cancelled and an `AuthorizationError.excessiveRefresh` error is thrown.
struct RefreshWindow {
    /// `TimeInterval` defining the duration of the time window before the current time in which the number of
    /// refresh attempts is compared against `maximumAttempts`. For example, if `interval` is 30 seconds, then the
    /// `RefreshWindow` represents the past 30 seconds. If more attempts occurred in the past 30 seconds than
    /// `maximumAttempts`, an `.excessiveRefresh` error will be thrown.
    let interval: TimeInterval

    /// Total refresh attempts allowed within `interval` before throwing an `.excessiveRefresh` error.
    let maximumAttempts: Int

    /// Creates a `RefreshWindow` instance from the specified `interval` and `maximumAttempts`.
    ///
    /// - Parameters:
    ///   - interval:        `TimeInterval` defining the duration of the time window before the current time.
    ///   - maximumAttempts: The maximum attempts allowed within the `TimeInterval`.
    init(interval: TimeInterval = 30.0, maximumAttempts: Int = 5) {
        self.interval = interval
        self.maximumAttempts = maximumAttempts
    }
}
