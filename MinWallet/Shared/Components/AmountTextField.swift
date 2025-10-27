import SwiftUI


struct AmountTextField: View {
    @Binding var value: String
    @Binding var minValue: Double
    @Binding var maxValue: Double?
    @Binding var minimumFractionDigits: Int?
    
    @State var fontPlaceHolder: Font = .paragraphSmall
    
    var body: some View {
        TextField("", text: $value)
            .placeholder("0.0", font: fontPlaceHolder, when: value.isEmpty)
            .keyboardType(.decimalPad)
            .lineLimit(1)
            .submitLabel(.done)
            .autocorrectionDisabled()
            .onChange(of: value) { newValue in
                value = AmountTextField.formatCurrency(newValue, minValue: minValue, maxValue: maxValue, minimumFractionDigits: minimumFractionDigits)
            }
    }
    
    static func formatCurrency(
        _ input: String,
        minValue: Double,
        maxValue: Double?,
        minimumFractionDigits: Int? = nil,
        isCheckFractionalPart: Bool = false
    ) -> String {
        var input = input
        if input.count > 1 && input.last == "," {
            input = String(input.dropLast(1)) + "."
        }
        
        let cleanedInput = input.replacingOccurrences(of: "[^0-9.]", with: "", options: .regularExpression)
        
        let components = cleanedInput.components(separatedBy: ".")
        var wholeNumber = components[0]
        var fractionalPart = components.count > 1 ? ".\(components[1])" : ""
        
        if !wholeNumber.isEmpty {
            let formatter = NumberFormatter()
            formatter.numberStyle = .decimal
            formatter.groupingSeparator = ","
            formatter.decimalSeparator = "."
            formatter.maximumFractionDigits = 0
            
            if let number = Int(wholeNumber), let formatted = formatter.string(from: NSNumber(value: number)) {
                wholeNumber = formatted
            }
            if let number = Int(wholeNumber), let formatted = formatter.string(from: NSNumber(value: number)) {
                wholeNumber = formatted
            }
        }
        
        if let minimumFractionDigits = minimumFractionDigits {
            fractionalPart = String(fractionalPart.prefix(minimumFractionDigits + 1))
        }
        
        let formattedValue = (isCheckFractionalPart && fractionalPart == ".") ? wholeNumber : (wholeNumber + fractionalPart)
        if let doubleValue = Double(formattedValue.replacingOccurrences(of: ",", with: "")), !input.isBlank, doubleValue > 0 {
            let clampedValue: Double = {
                guard let maxValue = maxValue else { return max(doubleValue, minValue) }
                return min(max(doubleValue, minValue), maxValue)
            }()

            if clampedValue != doubleValue {
                return clampedValue.formatSNumber()
            }
        }
        
        return formattedValue
    }
}
