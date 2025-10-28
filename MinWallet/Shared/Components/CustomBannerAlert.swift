import SwiftUI


private struct CustomBannerAlertModifier<InfoContent: View>: ViewModifier {
    @Binding var isShowing: Bool

    private let infoContent: () -> InfoContent

    init(
        isShowing: Binding<Bool>,
        @ViewBuilder infoContent: @escaping () -> InfoContent
    ) {
        _isShowing = isShowing
        self.infoContent = infoContent
    }

    func body(content: Content) -> some View {
        ZStack(alignment: .top) {
            content
            if isShowing {
                VStack(alignment: .center) {
                    infoContent()
                }
                .frame(width: UIScreen.main.bounds.width - .xl)
                .transition(
                    .asymmetric(
                        insertion: .move(edge: .top),
                        removal: .move(edge: .top)
                    )
                )
                .onTapGesture {
                    withAnimation {
                        self.isShowing = false
                    }
                }
                .onAppear(perform: {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 4) {
                        withAnimation {
                            self.isShowing = false
                        }
                    }
                })
                .zIndex(999)
            }
        }
    }
}

extension View {
    func banner<InfoContent: View>(
        isShowing: Binding<Bool>,
        @ViewBuilder infoContent: @escaping () -> InfoContent
    ) -> some View {
        self.modifier(CustomBannerAlertModifier(isShowing: isShowing, infoContent: infoContent))
    }
}


private struct LoadingViewModifier: ViewModifier {
    @Binding var isShowing: Bool

    init(isShowing: Binding<Bool>) {
        _isShowing = isShowing
    }

    func body(content: Content) -> some View {
        ZStack {
            content.opacity(isShowing ? 0 : 1)
            if isShowing {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: .blue))
                    .scaleEffect(1.0, anchor: .center)
            }
        }
    }
}

extension View {
    ///Using inside view
    func loading(isShowing: Binding<Bool>) -> some View {
        self.modifier(LoadingViewModifier(isShowing: isShowing))
    }
}


private struct ProgressViewModifier: ViewModifier {
    @Binding private var isShowing: Bool

    init(isShowing: Binding<Bool>) {
        _isShowing = isShowing
    }

    func body(content: Content) -> some View {
        content
            .overlay {
                if isShowing {
                    Color.black.opacity(0.2).ignoresSafeArea().transition(.fade)
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .blue))
                        .scaleEffect(2, anchor: .center)
                        .transition(.fade)
                        .zIndex(1000)
                }
            }
    }
}


extension View {
    ///Using overlay view
    func progressView(isShowing: Binding<Bool>) -> some View {
        self.modifier(ProgressViewModifier(isShowing: isShowing))
    }
}
