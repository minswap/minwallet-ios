import SwiftUI


/*
struct DashedUnderlineText: UIViewRepresentable {
    let text: LocalizedStringKey
    var textColor: UIColor = .white
    var font: UIFont? = .systemFont(ofSize: 14)

    func makeUIView(context: Context) -> UILabel {
        let text = text.toString()
        let label = UILabel()
        label.numberOfLines = 0
        label.setContentHuggingPriority(.required, for: .horizontal)
        label.setContentHuggingPriority(.required, for: .vertical)
        let attributedString = NSMutableAttributedString(string: text)
        let underlineStyle = NSUnderlineStyle.patternDash.rawValue | NSUnderlineStyle.single.rawValue

        attributedString.addAttribute(
            .underlineStyle,
            value: underlineStyle,
            range: NSRange(location: 0, length: attributedString.length)
        )

        attributedString.addAttributes(
            [
                NSAttributedString.Key.baselineOffset: 5,
                NSAttributedString.Key.font: font ?? .systemFont(ofSize: 14),
                NSAttributedString.Key.foregroundColor: textColor,

            ], range: NSRange(location: 0, length: attributedString.length))
        label.attributedText = attributedString
        return label
    }

    func updateUIView(_ uiView: UILabel, context: Context) {}
}
*/

extension LocalizedStringKey {
    func toString() -> String {
        let mirror = Mirror(reflecting: self)
        for child in mirror.children {
            if child.label == "key" {
                return child.value as? String ?? ""
            }
        }
        return ""
    }
}


struct DashedUnderlineText: View {
    let text: LocalizedStringKey
    @State var textColor: Color = .white
    @State var font: Font = .paragraphSmall
    @State
    private var width: CGFloat = 0

    var body: some View {
        VStack(spacing: 0) {
            Text(text)
                .font(font)
                .foregroundStyle(textColor)
                .padding(.bottom, 4)
                .padding(.top, 4)
                .background(
                    GeometryReader { geometry in
                        VStack {
                            Spacer()
                            DashedLine(lineWidth: 0.7, dash: [2.5, 2.5], color: textColor)
                                .frame(height: 0.7)
                        }
                    }
                )
        }
    }
}


struct DashedLine: View {
    var lineWidth: CGFloat = 0.7
    var dash: [CGFloat] = [6, 3]  // Dash length and gap
    var color: Color = .black

    var body: some View {
        GeometryReader { geometry in
            Path { path in
                path.move(to: CGPoint(x: 0, y: geometry.size.height / 2))
                path.addLine(to: CGPoint(x: geometry.size.width, y: geometry.size.height / 2))
            }
            .stroke(style: StrokeStyle(lineWidth: lineWidth, dash: dash))
            .foregroundColor(color)

        }
    }
}

struct SampleView: View {
    var body: some View {
        DashedUnderlineText(text: "Minimum Received", textColor: .colorInteractiveTentPrimarySub, font: .paragraphSmall)
    }
}

#Preview(body: {
    SampleView()
})
