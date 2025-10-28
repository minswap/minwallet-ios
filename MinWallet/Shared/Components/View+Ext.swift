import SwiftUI

extension View {
    func disableBounces() -> some View {
        modifier(DisableBouncesModifier())
    }
}

struct DisableBouncesModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .onAppear {
                UIScrollView.appearance().bounces = false
            }
            .onDisappear {
                UIScrollView.appearance().bounces = true
            }
    }
}

extension View {
    func placeholder<Content: View>(
        when shouldShow: Bool,
        alignment: Alignment = .leading,
        @ViewBuilder placeholder: () -> Content
    ) -> some View {

        ZStack(alignment: alignment) {
            placeholder().opacity(shouldShow ? 1 : 0)
            self
        }
    }

    func placeholder(
        _ text: String,
        font: Font = .paragraphSmall,
        when shouldShow: Bool,
        alignment: Alignment = .leading
    ) -> some View {

        placeholder(when: shouldShow, alignment: alignment) { Text(text).font(font).foregroundColor(.colorInteractiveTentPrimarySub) }
    }
}

struct DismissingKeyboard: ViewModifier {
    func body(content: Content) -> some View {
        content
            .onTapGesture {
                content.hideKeyboard()
            }
    }
}

extension View {

    func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}

extension View {
    func getFrame(onChange: @escaping (CGRect) -> Void) -> some View {
        background(
            GeometryReader { geo in
                Color.clear
                    .preference(key: FramePreferenceKey.self, value: geo.frame(in: .global))
            }
        )
        .onPreferenceChange(FramePreferenceKey.self, perform: onChange)
    }
}

private struct FramePreferenceKey: PreferenceKey {
    static var defaultValue: CGRect = .zero
    static func reduce(value: inout CGRect, nextValue: () -> CGRect) {}
}


extension UIApplication {
    static var safeArea: UIEdgeInsets {
        let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene
        return scene?.windows.first?.safeAreaInsets ?? .zero
    }
}

extension Binding where Value == String {
    func max(_ limit: Int) -> Self {
        if self.wrappedValue.count > limit {
            self.wrappedValue = String(self.wrappedValue.prefix(limit))

        }
        return self
    }
}

extension UIWindow {
    static var current: UIWindow? {
        for scene in UIApplication.shared.connectedScenes {
            guard let windowScene = scene as? UIWindowScene else { continue }
            for window in windowScene.windows {
                if window.isKeyWindow { return window }
            }
        }
        return nil
    }
}


extension UIScreen {
    static var current: UIScreen? {
        UIWindow.current?.screen
    }
}

extension MinWalletApp {
    static func openAppSettings() {
        if let settingsURL = URL(string: UIApplication.openSettingsURLString) {
            if UIApplication.shared.canOpenURL(settingsURL) {
                UIApplication.shared.open(settingsURL)
            }
        }
    }
}

extension View {
    func openAppNotificationSettings() {
        if let bundleIdentifier = Bundle.main.bundleIdentifier, let appSettings = URL(string: UIApplication.openSettingsURLString + bundleIdentifier) {
            if UIApplication.shared.canOpenURL(appSettings) {
                UIApplication.shared.open(appSettings)
            }
        }
    }
}

extension View {
    @ViewBuilder
    func applyKeyboardSafeArea(ignores: Bool) -> some View {
        if ignores {
            self.ignoresSafeArea(.keyboard)
        } else {
            self
        }
    }
}

extension Notification.Name {
    static let favDidChange = Notification.Name("favDidChange")
}
