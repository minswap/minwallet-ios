import Foundation
import Apollo
import MinWalletAPI
import OSLog
import SwiftyJSON


class MinWalletService {
    static let shared: MinWalletService = .init()
    
    private let apolloClient: ApolloClient
    
    private init() {
        apolloClient = ApolloClient(url: URL(string: MinWalletConstant.minGraphURL + "/graphql")!)
    }
    
    func fetch<Query: GraphQLQuery>(query: Query) async throws -> Query.Data? {
        #if DEBUG
            os_log("\(query.description) BEGIN")
        #endif
        return try await withCheckedThrowingContinuation { continuation in
            apolloClient.fetch(query: query, cachePolicy: .fetchIgnoringCacheData) { result in
                #if DEBUG
                    os_log("\(query.description) END")
                #endif
                switch result {
                case let .success(response):
                    if let errors = response.errors, !errors.isEmpty {
                        let msgError = errors.map({ $0.message ?? $0.description }).joined(separator: "\n")
                        continuation.resume(throwing: AppGeneralError.serverError(message: msgError))
                    } else {
                        continuation.resume(returning: response.data)
                    }
                case let .failure(error):
                    continuation.resume(throwing: AppGeneralError.serverError(message: Self.extractError(error)))
                }
            }
        }
    }
    
    func mutation<Mutation: GraphQLMutation>(mutation: Mutation) async throws -> Mutation.Data? {
        #if DEBUG
            os_log("\(mutation.description) BEGIN")
        #endif
        return try await withCheckedThrowingContinuation { continuation in
            apolloClient.perform(mutation: mutation) { result in
                #if DEBUG
                    os_log("\(mutation.description) END")
                #endif
                switch result {
                case let .success(response):
                    if let errors = response.errors, !errors.isEmpty {
                        let msgError = errors.map({ $0.message ?? $0.description }).joined(separator: "\n")
                        continuation.resume(throwing: AppGeneralError.serverError(message: msgError))
                    } else {
                        continuation.resume(returning: response.data)
                    }
                case let .failure(error):
                    continuation.resume(throwing: AppGeneralError.serverError(message: Self.extractError(error)))
                }
            }
        }
    }
}

extension GraphQLOperation {
    var description: String {
        /*
        let operation = "------Oper------:\n" + "\(String(describing: self))"
        let variables = "------Vars------:\n" + "\(self.__variables as AnyObject)"
        return operation + variables
         */
        return String(describing: self)
    }
}


extension MinWalletService {
    static func extractError(_ error: Error) -> String {
        guard let error = error as? ResponseCodeInterceptor.ResponseCodeError else { return error.localizedDescription }
        guard case let .invalidResponseCode(_, rawData) = error else { return error.localizedDescription }
        guard let data = rawData else { return error.localizedDescription }
        let json = JSON(data)
        let messages: [String] = json["errors"].arrayValue.compactMap { json in json["message"].string }
        guard !messages.isEmpty else { return error.localizedDescription }
        return messages.joined(separator: ", ")
    }
}

extension Error {
    var rawError: String {
        guard let error = self as? ResponseCodeInterceptor.ResponseCodeError else { return self.localizedDescription }
        guard case let .invalidResponseCode(_, rawData) = error else { return error.localizedDescription }
        guard let data = rawData else { return error.localizedDescription }
        let json = JSON(data)
        let messages: [String] = json["errors"].arrayValue.compactMap { json in json["message"].string }
        guard !messages.isEmpty else { return error.localizedDescription }
        return messages.joined(separator: ", ")
    }
}
