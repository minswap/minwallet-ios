import Foundation
import Alamofire
import Combine
import SwiftyJSON


func attempts<T>(
    maximumRetryCount: Int = 1,
    delayBeforeRetry: DispatchTimeInterval = .seconds(2),
    _ body: @escaping () async throws -> T
) async throws -> T {
    var attempts = 0
    func attempt() async throws -> T {
        attempts += 1
        do {
            return try await body()
        } catch {
            guard attempts < maximumRetryCount else { throw error }
            // Delay the task by 1 second:
            try? await Task.sleep(nanoseconds: delayBeforeRetry.nanoseconds)
            return try await attempt()
        }
    }
    return try await attempt()
}

func attempts<T>(
    maximumRetryCount: Int = 1,
    delayBeforeRetry: DispatchTimeInterval = .seconds(2),
    errorCondition: @escaping (Error) -> Bool,
    _ body: @escaping () async throws -> T
) async throws -> T {
    var attempts = 0
    func attempt() async throws -> T {
        attempts += 1
        do {
            return try await body()
        } catch {
            guard errorCondition(error),
                attempts < maximumRetryCount
            else { throw error }
            try? await Task.sleep(nanoseconds: delayBeforeRetry.nanoseconds)
            return try await attempt()
        }
    }
    return try await attempt()
}


// MARK: - Alamofire debug log
extension Alamofire.Request {
    func debugLog(_ printFlag: Bool = false) -> Self {
        if printFlag {
            print(">>>> Request -LOG-START- >>>>")
            return cURLDescription { curl in
                print(curl)
                print(">>>> Request -LOG-END- >>>>")
            }
        }
        return self
    }
}

extension Alamofire.DataResponse {
    @discardableResult
    func debugLog(_ printFlag: Bool = false) -> Self {
        if printFlag {
            print(">>>> Response -LOG-START- >>>>")
            print("==== Response Request: ", request?.url ?? "", " ====")
            switch result {
            case let .success(data):
                guard let data = data as? Data,
                    let value = try? JSONSerialization.jsonObject(with: data)
                else {
                    print("Error: Response isn't JSON Object")
                    return self
                }

                if !JSONSerialization.isValidJSONObject(value) {
                    print("Error: Response isn't JSON Object")
                } else if let jsonData = try? JSONSerialization.data(withJSONObject: value as AnyObject, options: [.prettyPrinted]),
                    let jsonString = String(data: jsonData, encoding: .utf8)
                {
                    print(jsonString)
                } else {
                    print("Error: Can't parse response to JSON")
                }
            case let .failure(error):
                print("Error: ", error.localizedDescription)
            }
            print(">>>> Response -LOG-END- >>>>")
        }

        return self
    }
}

extension DispatchTimeInterval {
    var nanoseconds: UInt64 {
        let now = DispatchTime.now()
        let later = now + self
        return later.uptimeNanoseconds - now.uptimeNanoseconds
    }
}
