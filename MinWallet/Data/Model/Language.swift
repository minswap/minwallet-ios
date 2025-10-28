import Foundation
import Then

extension AppSetting {
    enum TimeZone: String {
        case local = "Local"
        case utc = "UTC"
    }
}

enum Currency: String {
    case usd = "USD"
    case ada = "ADA"

    var prefix: String {
        switch self {
        case .usd:
            return "$"
        case .ada:
            return MinWalletConstant.adaCurrency
        }
    }
}

enum Language: String, CaseIterable, Identifiable {
    var id: String { UUID().uuidString }

    case english = "en"
    case afrikaans = "af"
    case arabic = "ar"
    case bengali = "bn"
    case catala = "ca"
    case cestina = "cs"
    case dansk = "da"
    case deutsch = "nl"
    case espanol = "es"
    case persian = "fa"
    case suomalainen = "fi"
    case filipino = "fil"

    var locale: Locale {
        Locale(identifier: rawValue)
    }

    var title: String {
        switch self {
        case .english:
            return "English"
        case .afrikaans:
            return "Afrikaans"
        case .arabic:
            return "العربية"
        case .bengali:
            return "বাংলা"
        case .catala:
            return "Català"
        case .cestina:
            return "čeština"
        case .dansk:
            return "Dansk"
        case .deutsch:
            return "Deutsch"
        case .espanol:
            return "Español"
        case .persian:
            return "فارسی"
        case .suomalainen:
            return "Suomalainen"
        case .filipino:
            return "Filipino"
        }
    }
}
