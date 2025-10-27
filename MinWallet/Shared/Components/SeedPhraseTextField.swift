import SwiftUI
import UIKit

struct SeedPhraseTextField: View {
    @Binding var text: String
    let typingColor: UIColor  // Color for text currently being typed
    let completedColor: UIColor  // Color for text after a space
    
    @State private var dynamicHeight: CGFloat = 50
    private var onCommit: (() -> Void)?
    
    init(
        text: Binding<String>,
        typingColor: UIColor,
        completedColor: UIColor,
        onCommit: (() -> Void)? = nil
    ) {
        self._text = text
        self.typingColor = typingColor
        self.completedColor = completedColor
        self.onCommit = onCommit
    }
    
    var body: some View {
        UITextViewWrapper(
            text: $text,
            typingColor: typingColor,
            completedColor: completedColor,
            calculatedHeight: $dynamicHeight,
            onDone: onCommit
        )
        .frame(minHeight: dynamicHeight, maxHeight: dynamicHeight)
    }
    
}

private struct UITextViewWrapper: UIViewRepresentable {
    @Binding var text: String
    let typingColor: UIColor  // Color for text currently being typed
    let completedColor: UIColor  // Color for text after a space
    
    @Binding var calculatedHeight: CGFloat
    var onDone: (() -> Void)?
    
    func makeUIView(context: Context) -> UITextView {
        let textView = UITextView()
        textView.delegate = context.coordinator
        textView.isScrollEnabled = true
        textView.backgroundColor = .clear
        textView.font = UIFontMetrics(forTextStyle: .body).scaledFont(for: .paragraphSmall ?? .systemFont(ofSize: 14))
        textView.adjustsFontForContentSizeCategory = true
        textView.autocorrectionType = .no
        textView.bounces = false
        // Configure the placeholder label
        let placeholderLabel = UILabel()
        placeholderLabel.text = "Please write down your seed phrase ..."
        placeholderLabel.textColor = .colorInteractiveTentPrimarySub
        placeholderLabel.font = UIFontMetrics(forTextStyle: .body).scaledFont(for: .paragraphSmall ?? .systemFont(ofSize: 14))
        placeholderLabel.adjustsFontForContentSizeCategory = true
        placeholderLabel.translatesAutoresizingMaskIntoConstraints = false
        placeholderLabel.numberOfLines = 2
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
        uiView.attributedText = context.coordinator.getAttributedText(from: text, typingColor: typingColor, completedColor: completedColor)
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
            let sanitizedText = sanitizeInput(textView.text ?? "")
            
            if sanitizedText != parent.text {
                parent.text = sanitizedText
                textView.attributedText = getAttributedText(from: sanitizedText, typingColor: parent.typingColor, completedColor: parent.completedColor)
            }
            
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
        
        // Sanitize input to remove extra spaces
        private func sanitizeInput(_ text: String) -> String {
            let components = text.components(separatedBy: .whitespacesAndNewlines)
            let filteredComponents = components.filter { !$0.isEmpty }
            return filteredComponents.joined(separator: " ") + (text.last == " " ? " " : "")
        }
        
        // Generate attributed text with the desired coloring
        func getAttributedText(from text: String, typingColor: UIColor, completedColor: UIColor) -> NSAttributedString {
            let attributedString = NSMutableAttributedString(string: text)
            
            let words = text.split(separator: " ", omittingEmptySubsequences: false)
            
            // Apply color to each word or segment
            var startIndex = 0
            for (index, word) in words.enumerated() {
                let wordRange = NSRange(location: startIndex, length: word.count)
                let color = (index == words.count - 1 && !text.hasSuffix(" ")) ? typingColor : completedColor
                attributedString.addAttribute(.foregroundColor, value: color, range: wordRange)
                attributedString.addAttribute(.font, value: UIFontMetrics(forTextStyle: .body).scaledFont(for: .paragraphSmall ?? .systemFont(ofSize: 14)), range: wordRange)
                // Update the start index for the next word
                startIndex += word.count + 1  // Account for the space
            }
            
            return attributedString
        }
    }
    
    func updatePlaceholder(_ textView: UITextView) {
        if let placeholderLabel = textView.viewWithTag(999) as? UILabel {
            placeholderLabel.isHidden = !text.isEmpty
        }
    }
}


#Preview {
    ReInputSeedPhraseView(screenType: .restoreWallet)
}
