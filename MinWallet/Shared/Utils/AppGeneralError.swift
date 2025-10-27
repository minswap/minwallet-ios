import SwiftUI
import SwiftyJSON


enum AppGeneralError: LocalizedError {
    
    case localErrorLocalized(message: LocalizedStringKey)
    case serverErrorLocalized(message: LocalizedStringKey)
    case invalidResponseErrorLocalized(message: LocalizedStringKey)
    
    case serverError(message: String)
    case invalidResponseError(message: String)
    
    var errorDescription: String? {
        switch self {
        case .serverError(let message),
            .invalidResponseError(let message):
            return message
        case .localErrorLocalized(let message),
            .serverErrorLocalized(let message),
            .invalidResponseErrorLocalized(let message):
            return message.toString()
        }
    }
}
