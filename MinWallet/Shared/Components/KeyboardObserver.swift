import SwiftUI


class KeyboardObserver: ObservableObject {
    static let shared = KeyboardObserver()
    
    @Published var keyboardHeight: CGFloat = 0
    
    private init() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(notification:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(notification:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    @objc
    private func keyboardWillShow(notification: Notification) {
        if let rect = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect {
            DispatchQueue.main.async {
                withAnimation {
                    self.keyboardHeight = rect.height
                }
            }
        }
    }
    
    @objc
    private func keyboardWillHide(notification: Notification) {
        DispatchQueue.main.async {
            withAnimation {
                self.keyboardHeight = 0
            }
        }
    }
}
