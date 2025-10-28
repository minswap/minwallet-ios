import Foundation


enum PasswordValidation: String, CaseIterable, Identifiable {
    var id: String { UUID().uuidString }

    case atLeast12Character = "At least 12 characters"
    case atLeast1CapitalLetter = "At least 1 capital letter"
    case atLeast1Number = "At least 1 number"
    case atLeast1SpecialCharacter = "At least 1 special character"
}

extension PasswordValidation {
    static func validateInput(password: String) -> [PasswordValidation] {
        var validationMatched: [PasswordValidation] = []
        if password.count >= 12 {
            validationMatched.append(.atLeast12Character)
        }

        if password.rangeOfCharacter(from: .uppercaseLetters) != nil {
            validationMatched.append(.atLeast1CapitalLetter)
        }

        if password.rangeOfCharacter(from: .decimalDigits) != nil {
            validationMatched.append(.atLeast1Number)
        }

        let regex = "[^a-zA-Z0-9]"  // Matches any character that is not a letter or number
        if password.range(of: regex, options: .regularExpression) != nil {
            validationMatched.append(.atLeast1SpecialCharacter)
        }

        return validationMatched
    }
}
