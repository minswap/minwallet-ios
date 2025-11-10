import SwiftUI
import UIKit


fileprivate func presentSystemAlert(title: String,
                                    message: String,
                                    okTitle: String = "OK",
                                    cancelTitle: String? = nil,
                                    onOK: (() -> Void)? = nil,
                                    onCancel: (() -> Void)? = nil) {
    DispatchQueue.main.async {
        guard let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let root = scene.windows.first?.rootViewController else { return }
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        if let cancelTitle {
            alert.addAction(UIAlertAction(title: cancelTitle, style: .cancel) { _ in
                onCancel?()
            })
        }
        
        alert.addAction(UIAlertAction(title: okTitle, style: .default) { _ in
            onOK?()
        })
        
        root.present(alert, animated: true)
    }
}

struct SystemAlertModifier: ViewModifier {
    @Binding var isPresented: Bool
    let title: String
    @Binding
    var message: String
    let okTitle: String
    let cancelTitle: String?
    let onOK: (() -> Void)?
    let onCancel: (() -> Void)?
    
    func body(content: Content) -> some View {
        content
            .onChange(of: isPresented) { newValue in
                if newValue {
                    presentSystemAlert(
                        title: title,
                        message: message,
                        okTitle: okTitle,
                        cancelTitle: cancelTitle,
                        onOK: onOK,
                        onCancel: onCancel
                    )
                    DispatchQueue.main.async {
                        isPresented = false
                    }
                }
            }
    }
}

extension View {
    func showSystemAlert(_ isPresented: Binding<Bool>,
                         title: LocalizedStringKey = "Notice",
                         message: Binding<String>,
                         okTitle: LocalizedStringKey = "OK",
                         cancelTitle: LocalizedStringKey? = nil,
                         onOK: (() -> Void)? = nil,
                         onCancel: (() -> Void)? = nil) -> some View {
        self.modifier(SystemAlertModifier(isPresented: isPresented,
                                          title: title.toString(),
                                          message: message,
                                          okTitle: okTitle.toString(),
                                          cancelTitle: cancelTitle?.toString(),
                                          onOK: onOK,
                                          onCancel: onCancel))
    }
    
    func showSystemAlert(_ isPresented: Binding<Bool>,
                         title: LocalizedStringKey = "Notice",
                         messageString: LocalizedStringKey,
                         okTitle: LocalizedStringKey = "OK",
                         cancelTitle: LocalizedStringKey? = nil,
                         onOK: (() -> Void)? = nil,
                         onCancel: (() -> Void)? = nil) -> some View {
        self.modifier(SystemAlertModifier(isPresented: isPresented,
                                          title: title.toString(),
                                          message: .constant(messageString.toString()),
                                          okTitle: okTitle.toString(),
                                          cancelTitle: cancelTitle?.toString(),
                                          onOK: onOK,
                                          onCancel: onCancel))
    }
}
