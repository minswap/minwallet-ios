import SwiftUI

extension String {
    var shortenAddress: String {
        if self.count <= 12 {
            return self
        }

        let first6Characters = self.prefix(6)
        let last6Characters = self.suffix(6)
        return "\(first6Characters)...\(last6Characters)"
    }

    var doubleValue: Double {
        Double(self.replacingOccurrences(of: ",", with: "")) ?? 0
    }

    var hexToText: String? {
        var hexStr = self
        var text = ""

        while hexStr.count >= 2 {
            let hexChar = String(hexStr.prefix(2))
            hexStr = String(hexStr.dropFirst(2))

            if let charCode = UInt8(hexChar, radix: 16) {
                text.append(Character(UnicodeScalar(charCode)))
            } else {
                return nil
            }
        }

        return text
    }

    var formattedDateGMT: String {
        let inputDateString = self

        let inputFormatter = DateFormatter()
        inputFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"
        inputFormatter.locale = Locale(identifier: "en_US_POSIX")
        inputFormatter.timeZone = .gmt
        guard let date = inputFormatter.date(from: inputDateString) else {
            return self
        }

        let outputFormatter = DateFormatter()
        outputFormatter.dateFormat = "yyyy-MM-dd HH:mm 'GMT'XXX"

        outputFormatter.locale = Locale(identifier: "en_US_POSIX")
        if AppSetting.shared.timeZone == AppSetting.TimeZone.utc.rawValue {
            outputFormatter.timeZone = .gmt
            return outputFormatter.string(from: date).replacingOccurrences(of: "Z", with: "")
        }

        return outputFormatter.string(from: date)
    }

    var formatToDate: Date {
        let inputDateString = self

        let inputFormatter = DateFormatter()
        inputFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"
        inputFormatter.locale = Locale(identifier: "en_US_POSIX")
        inputFormatter.timeZone = .gmt
        return inputFormatter.date(from: inputDateString) ?? Date()
    }

    var adaName: String? {
        let prefix = self.prefix(8)
        if prefix.first == "0" && prefix.last == "0" && self.count >= 8 {
            if let hexToText = String(self.dropFirst(8)).hexToText, hexToText.isHumanReadable {
                return hexToText
            }
        }
        if let hexToText = self.hexToText, hexToText.isHumanReadable {
            return hexToText
        }

        if self.count <= 10 {
            return self
        }

        if self.count > 10 {
            return String(self.prefix(10) + "...")
        }

        return self
    }

    var isHumanReadable: Bool {
        do {
            let pattern = #"^[\w\s\[\].,-]*$"#

            let regex = try NSRegularExpression(pattern: pattern)
            let range = NSRange(location: 0, length: self.utf16.count)
            let match = regex.firstMatch(in: self, options: [], range: range)

            return match != nil
        } catch {
            return false
        }
    }

    var isAdaHandleName: Bool {
        self.range(of: MinWalletConstant.adaHandleRegex, options: .regularExpression) != nil
    }

    func viewTransaction() {
        guard let url = URL(string: MinWalletConstant.transactionURL + "/transaction/" + self) else { return }
        UIApplication.shared.open(url, options: [:], completionHandler: nil)
    }

    func openURL() {
        guard let url = URL(string: self) else { return }
        UIApplication.shared.open(url, options: [:], completionHandler: nil)
    }
}

extension Data {
    var hexString: String {
        let hexString = map { String(format: "%02.2hhx", $0) }.joined()
        return hexString
    }
}


extension Double {
    func formatSNumber(usesGroupingSeparator: Bool = true, maximumFractionDigits: Int = 15) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.groupingSeparator = ","
        formatter.usesGroupingSeparator = usesGroupingSeparator
        formatter.decimalSeparator = "."
        formatter.maximumFractionDigits = maximumFractionDigits
        formatter.minimumFractionDigits = 0
        return formatter.string(from: NSNumber(value: self)) ?? ""
    }

    func formatNumber(
        prefix: String = "",
        suffix: String = "",
        roundingOffset: Int? = 3,
        font: Font = .labelMediumSecondary,
        fontColor: Color = .colorBaseTent,
        isFormatK: Bool = false
    ) -> AttributedString {
        var prefix: AttributedString = AttributedString(prefix)
        prefix.font = font
        prefix.foregroundColor = fontColor
        var suffix: AttributedString = AttributedString(suffix.isEmpty ? "" : " \(suffix)")
        suffix.font = font
        suffix.foregroundColor = fontColor

        var result = AttributedString(self.formatted())
        result.font = font
        result.foregroundColor = fontColor

        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.groupingSeparator = ","
        formatter.usesGroupingSeparator = true
        formatter.decimalSeparator = "."
        formatter.maximumFractionDigits = 15
        formatter.minimumFractionDigits = 0

        guard let formattedString = formatter.string(from: NSNumber(value: self))
        else {
            prefix.append(result)
            prefix.append(suffix)
            return prefix
        }

        if isFormatK && self >= 1_000_000 {
            let millionNum = self / 1_000_000
            let billionNum = self / 1_000_000_000

            formatter.maximumFractionDigits = 2

            let value: String = {
                if self >= 1_000_000_000 {
                    return (formatter.string(from: NSNumber(value: billionNum)) ?? "") + "B"
                } else if self >= 1_000_000 {
                    return (formatter.string(from: NSNumber(value: millionNum)) ?? "") + "M"
                } else {
                    return self.formatted()
                }
            }()
            var result = AttributedString(value)
            result.font = font
            result.foregroundColor = fontColor
            prefix.append(result)
            prefix.append(suffix)
            return prefix
        }

        result = AttributedString(formattedString)
        result.font = font
        result.foregroundColor = fontColor

        let components = formattedString.components(separatedBy: ".")

        guard components.count > 1
        else {
            prefix.append(result)
            prefix.append(suffix)
            return prefix
        }

        let decimalPart = components[1]

        result = AttributedString("")
        result.append(AttributedString(components[0] + "."))

        var zerosCount = 0
        var startIndex = decimalPart.startIndex

        for char in decimalPart {
            if char == "0" {
                zerosCount += 1
            } else {
                break
            }
            startIndex = decimalPart.index(after: startIndex)
        }

        let roundingIndex: String.Index = {
            if let roundingOffset = roundingOffset {
                return decimalPart.index(startIndex, offsetBy: roundingOffset, limitedBy: decimalPart.endIndex) ?? decimalPart.endIndex
            }
            return decimalPart.endIndex
        }()

        let roundedDecimal = String(decimalPart[startIndex..<roundingIndex])

        if zerosCount >= 4 && roundingOffset != nil {
            result.append(AttributedString("0"))
            result.font = font
            result.foregroundColor = fontColor

            var subscriptText = AttributedString(String(zerosCount))
            subscriptText.font = .paragraphXSmall
            subscriptText.foregroundColor = fontColor
            subscriptText.baselineOffset = -4

            result.append(subscriptText)

            var roundedAtt = AttributedString(roundedDecimal)
            roundedAtt.font = font
            roundedAtt.foregroundColor = fontColor
            result.append(roundedAtt)
        } else {
            let subNumber = String(repeating: "0", count: zerosCount)
            result.append(AttributedString(subNumber))
            result.append(AttributedString(roundedDecimal))
            result.font = font
            result.foregroundColor = fontColor
        }

        prefix.append(result)
        prefix.append(suffix)
        return prefix
    }
}


extension NSAttributedString {

    func gkWidth(consideringHeight height: CGFloat) -> CGFloat {
        let size = self.gkSize(consideringHeight: height)
        return size.width
    }

    func gkHeight(consideringWidth width: CGFloat) -> CGFloat {
        let size = self.gkSize(consideringWidth: width)
        return size.height
    }

    func gkSize(consideringHeight height: CGFloat) -> CGSize {
        let constraintRect = CGSize(width: .greatestFiniteMagnitude, height: height)
        return self.gkSize(consideringRect: constraintRect)
    }

    func gkSize(consideringWidth width: CGFloat) -> CGSize {
        let constraintRect = CGSize(width: width, height: .greatestFiniteMagnitude)
        return self.gkSize(consideringRect: constraintRect)
    }

    func gkSize(consideringRect size: CGSize) -> CGSize {
        let rect =
            self.boundingRect(
                with: size,
                options: [.usesLineFragmentOrigin, .usesFontLeading],
                context: nil
            )
            .integral
        return rect.size
    }
}

extension String {
    func toExact(decimal: Double) -> Double {
        return self.doubleValue / pow(10.0, decimal)
    }
    func toExact(decimal: Int) -> Double {
        return self.doubleValue / pow(10.0, Double(decimal))
    }

    func toSendBE(decimal: Int) -> Double {
        return self.doubleValue * pow(10.0, Double(decimal))
    }
}

extension Double {
    func toExact(decimal: Double?) -> Double {
        return self / pow(10.0, decimal ?? 0)
    }
}

extension Double {
    func toExact(decimal: Int?) -> Double {
        return self / pow(10.0, Double(decimal ?? 0))
    }
}

extension String {
    func getPriceValue(appSetting: AppSetting, isFormatK: Bool = false) -> (value: Double, attribute: AttributedString) {
        let price = Double(self) ?? 0
        switch appSetting.currency {
        case Currency.ada.rawValue:
            return (price, price.formatNumber(suffix: Currency.ada.prefix))
        default:
            //return (price, (price * appSetting.currencyInADA).formatNumber(prefix: Currency.usd.prefix, isFormatK: isFormatK))
            return (price, price.formatNumber(prefix: Currency.usd.prefix, isFormatK: isFormatK))
        }
    }
}

extension Double {
    func getPriceValue(appSetting: AppSetting, font: Font = .labelMediumSecondary, roundingOffset: Int? = 3, fontColor: Color = .colorBaseTent, isFormatK: Bool = false) -> (value: Double, attribute: AttributedString) {
        let price = self
        switch appSetting.currency {
        case Currency.ada.rawValue:
            return (price, price.formatNumber(suffix: Currency.ada.prefix, roundingOffset: roundingOffset, font: font))
        default:
            return (price, price.formatNumber(prefix: Currency.usd.prefix, roundingOffset: roundingOffset, font: font, fontColor: fontColor, isFormatK: isFormatK))
        //            return (price, (price * appSetting.currencyInADA).formatNumber(prefix: Currency.usd.prefix, roundingOffset: roundingOffset, font: font, fontColor: fontColor, isFormatK: isFormatK))
        }
    }
}

extension Dictionary {
    @inlinable mutating func append(_ other: [Key: Value]) {
        return self.merge(other, uniquingKeysWith: { $1 })
    }

    @inlinable func appending(_ other: [Key: Value]) -> [Key: Value] {
        return self.merging(other, uniquingKeysWith: { $1 })
    }

    static func + (lhs: [Key: Value], rhs: [Key: Value]) -> [Key: Value] {
        return lhs.appending(rhs)
    }
}

extension String {
    ///xxxx -> xxx.yyy
    var toPolicyIdWithDot: String {
        guard self.count >= 56 else { return self }

        let policyIdHex = String(self.prefix(56))
        let tokenNameHex = String(self.dropFirst(56))

        return policyIdHex + "." + tokenNameHex
    }

    var toPolicyIdWithoutDot: String {
        self.replacingOccurrences(of: ".", with: "")
    }

    var tokenDefault: TokenProtocol {
        let policyIdWithDot = toPolicyIdWithDot.split(separator: ".")
        let currencySymbol: String = String(policyIdWithDot.first ?? "")
        let tokenName: String = String(policyIdWithDot.last ?? "")
        return TokenDefault(symbol: currencySymbol, tName: policyIdWithDot.count == 2 ? tokenName : "")
    }
}
