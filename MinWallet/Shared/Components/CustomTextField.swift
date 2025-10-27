import SwiftUI
import UIKit


struct CustomTextField: View {
    @Binding var text: String
    @Binding var enableTextView: Bool
    
    let font: UIFont
    let textColor: UIColor
    
    let placeHolderTextColor: UIColor
    let placeHolderText: LocalizedStringKey
    
    @State private var dynamicHeight: CGFloat = 44
    private var onCommit: (() -> Void)?
    
    init(
        text: Binding<String>,
        enableTextView: Binding<Bool>,
        font: UIFont,
        textColor: UIColor,
        placeHolderTextColor: UIColor,
        placeHolderText: LocalizedStringKey,
        onCommit: (() -> Void)? = nil
    ) {
        self._text = text
        self._enableTextView = enableTextView
        self.font = font
        self.textColor = textColor
        self.placeHolderTextColor = placeHolderTextColor
        self.placeHolderText = placeHolderText
        self.onCommit = onCommit
    }
    
    var body: some View {
        UITextViewWrapper(
            text: $text,
            enableTextView: $enableTextView,
            font: font,
            textColor: textColor,
            placeHolderTextColor: placeHolderTextColor,
            placeHolderText: placeHolderText,
            calculatedHeight: $dynamicHeight,
            onDone: onCommit
        )
        .frame(minHeight: dynamicHeight, maxHeight: dynamicHeight)
    }
}

private struct UITextViewWrapper: UIViewRepresentable {
    @Binding var text: String
    @Binding var enableTextView: Bool
    
    let font: UIFont
    let textColor: UIColor
    
    let placeHolderTextColor: UIColor
    let placeHolderText: LocalizedStringKey
    
    @Binding var calculatedHeight: CGFloat
    var onDone: (() -> Void)?
    
    func makeUIView(context: Context) -> UITextView {
        let textView = UITextView()
        textView.delegate = context.coordinator
        textView.isScrollEnabled = true
        textView.backgroundColor = .clear
        textView.font = UIFontMetrics(forTextStyle: .body).scaledFont(for: font)
        textView.textColor = textColor
        textView.isUserInteractionEnabled = enableTextView
        textView.bounces = false
        textView.adjustsFontForContentSizeCategory = true
        textView.autocorrectionType = .no
        let placeholderLabel = UILabel()
        placeholderLabel.text = placeHolderText.toString()
        placeholderLabel.textColor = placeHolderTextColor
        placeholderLabel.font = UIFontMetrics(forTextStyle: .body).scaledFont(for: .paragraphSmall ?? .systemFont(ofSize: 14))
        placeholderLabel.adjustsFontForContentSizeCategory = true
        placeholderLabel.translatesAutoresizingMaskIntoConstraints = false
        textView.addSubview(placeholderLabel)
        
        NSLayoutConstraint.activate([
            placeholderLabel.leadingAnchor.constraint(equalTo: textView.leadingAnchor, constant: 5),
            placeholderLabel.trailingAnchor.constraint(equalTo: textView.trailingAnchor, constant: -5),
            placeholderLabel.topAnchor.constraint(equalTo: textView.topAnchor, constant: 8),
        ])
        
        placeholderLabel.tag = 999  // Use a tag to identify the placeholder
        placeholderLabel.isHidden = !text.isEmpty  // Show or hide based on the initial text
        
        textView.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        
        return textView
    }
    
    func updateUIView(_ uiView: UITextView, context: Context) {
        uiView.text = text
        uiView.isUserInteractionEnabled = enableTextView
        updatePlaceholder(uiView)
        UITextViewWrapper.recalculateHeight(view: uiView, result: $calculatedHeight)
    }
    
    fileprivate static func recalculateHeight(view: UIView, result: Binding<CGFloat>) {
        let newSize = view.sizeThatFits(CGSize(width: view.frame.size.width, height: CGFloat.greatestFiniteMagnitude))
        if result.wrappedValue != newSize.height {
            DispatchQueue.main.async {
                result.wrappedValue = newSize.height
            }
        }
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self, height: $calculatedHeight, onDone: onDone)
    }
    
    class Coordinator: NSObject, UITextViewDelegate {
        var parent: UITextViewWrapper
        var calculatedHeight: Binding<CGFloat>
        var onDone: (() -> Void)?
        
        init(_ parent: UITextViewWrapper, height: Binding<CGFloat>, onDone: (() -> Void)?) {
            self.parent = parent
            self.calculatedHeight = height
            self.onDone = onDone
        }
        
        func textViewDidChange(_ textView: UITextView) {
            parent.text = textView.text
            parent.updatePlaceholder(textView)
            UITextViewWrapper.recalculateHeight(view: textView, result: calculatedHeight)
        }
        
        func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
            if text == "\n" {
                onDone?()
                textView.resignFirstResponder()
                return false
            }
            return true
        }
    }
    
    func updatePlaceholder(_ textView: UITextView) {
        if let placeholderLabel = textView.viewWithTag(999) as? UILabel {
            placeholderLabel.isHidden = !text.isEmpty
        }
    }
}


#Preview {
    VStack {
        CustomTextField(
            text: .constant("HUhu"),
            enableTextView: .constant(true),
            font: .labelSmallSecondary ?? .systemFont(ofSize: 14),
            textColor: .colorBaseTent,
            placeHolderTextColor: .black,
            placeHolderText: "Enter address or ADAHandle",
            onCommit: {}
        )
    }
}
