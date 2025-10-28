import SwiftUI
import SwiftyAttributes


struct TextLearnMoreSendTokenView: UIViewRepresentable {
    let text: LocalizedStringKey
    let textClickAble: LocalizedStringKey

    var preferredMaxLayoutWidth: CGFloat = .greatestFiniteMagnitude

    func makeUIView(context: Context) -> UILabel {
        let label = UILabel()
        label.numberOfLines = 0
        label.isUserInteractionEnabled = true
        label.font = .paragraphSmall
        label.setContentHuggingPriority(.required, for: .vertical)
        label.setContentCompressionResistancePriority(.required, for: .vertical)
        label.setContentHuggingPriority(.defaultLow, for: .horizontal)
        label.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)

        let tapGesture = UITapGestureRecognizer(target: context.coordinator, action: #selector(context.coordinator.onViewTap(recognizer:)))
        tapGesture.delegate = context.coordinator
        tapGesture.numberOfTapsRequired = 1
        label.addGestureRecognizer(tapGesture)

        context.coordinator.label = label

        return label
    }

    func updateUIView(_ uiView: UILabel, context: Context) {
        context.coordinator.label = uiView
        uiView.attributedText = context.coordinator.getAttributedText(text: text, textClickAble: textClickAble)
        uiView.preferredMaxLayoutWidth = preferredMaxLayoutWidth
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject, UIGestureRecognizerDelegate {
        var parent: TextLearnMoreSendTokenView
        weak var label: UILabel?
        var text: LocalizedStringKey = ""
        var textClickAble: LocalizedStringKey = ""

        init(_ parent: TextLearnMoreSendTokenView) {
            self.parent = parent
        }

        @objc
        func onViewTap(recognizer: UITapGestureRecognizer) {
            guard let label = self.label,
                let text = label.attributedText?.string
            else {
                return
            }

            if let range = text.range(of: textClickAble.toString()),
                recognizer.didTapAttributedTextInLabel(label: label, inRange: NSRange(range, in: text))
            {
                UIApplication.shared.open(URL(string: "https://google.com")!, options: [:], completionHandler: nil)
            }
        }

        func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
            return true
        }

        func getAttributedText(text: LocalizedStringKey, textClickAble: LocalizedStringKey) -> NSAttributedString {
            self.text = text
            self.textClickAble = textClickAble
            let attributedString = NSMutableAttributedString()
                .then {
                    $0.append(
                        text.toString()
                            .withAttributes([
                                .font(UIFont.systemFont(ofSize: 15, weight: .regular)),
                                .textColor(UIColor.colorInteractiveTentPrimarySub),
                            ]))
                    $0.append(
                        textClickAble.toString()
                            .withAttributes([
                                .font(UIFont.systemFont(ofSize: 15, weight: .regular)),
                                .textColor(UIColor.colorInteractiveTentSecondaryDefault),
                                .underlineStyle(.single),
                                //                                                    .baselineOffset(0)
                            ]))
                    $0.append(NSAttributedString(string: " "))
                }

            let textAttachment = NSTextAttachment()
            textAttachment.image = UIImage(resource: .icExternalLink)
            textAttachment.bounds = CGRect(x: 0, y: -2, width: 16, height: 16)
            let imageString = NSAttributedString(attachment: textAttachment)
            attributedString.append(imageString)

            return attributedString
        }
    }
}


struct HorizontalGeometryReader<Content: View>: View {
    var content: (CGFloat) -> Content
    @State private var width: CGFloat = 0

    public init(@ViewBuilder content: @escaping (CGFloat) -> Content) {
        self.content = content
    }

    public var body: some View {
        content(width)
            .frame(minWidth: 0, maxWidth: .infinity)
            .background(
                GeometryReader { geometry in
                    Color.clear
                        .preference(key: WidthPreferenceKey.self, value: geometry.size.width)
                }
            )
            .onPreferenceChange(WidthPreferenceKey.self) { width in
                self.width = width
            }
    }
}

fileprivate struct WidthPreferenceKey: PreferenceKey, Equatable {
    static var defaultValue: CGFloat = 0
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
    }
}
