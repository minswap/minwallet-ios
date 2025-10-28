import SwiftUI


private struct ModalTypeView<Modal: View>: ViewModifier {
    @Binding var isPresented: Bool
    @State private var dragOffset: CGFloat = 0
    @State var modalHeight: CGFloat?
    @ViewBuilder var modal: () -> Modal
    @State private var enableDragGesture: Bool = true

    var onDimiss: (() -> Void)?

    func body(content: Content) -> some View {
        ZStack {
            content
            VisualEffectBlurView(blurRadius: 2)
                .ignoresSafeArea()
                .transition(.opacity)
                .opacity(isPresented ? 1 : 0)
                .onTapGesture {
                    withAnimation {
                        content.hideKeyboard()
                        isPresented.toggle()
                        onDimiss?()
                    }
                }
        }
        .overlay(alignment: .bottom) {
            modal()
                .frame(height: modalHeight)
                .opacity(isPresented ? 1 : 0)
                .offset(y: isPresented ? dragOffset : 1000)
                .gesture(
                    DragGesture()
                        .onChanged { value in
                            guard enableDragGesture else { return }
                            if value.translation.height > 0 {
                                dragOffset = value.translation.height
                            }
                        }
                        .onEnded { value in
                            guard enableDragGesture else { return }
                            if value.translation.height > 100 {
                                withAnimation {
                                    content.hideKeyboard()
                                    isPresented = false
                                    onDimiss?()
                                }
                            }
                            dragOffset = 0
                        }
                )
        }
        .environment(
            \.enableDragGesture,
            { enabled in
                enableDragGesture = enabled
            }
        )
        .environment(
            \.partialSheetDismiss,
            {
                withAnimation {
                    content.hideKeyboard()
                    isPresented = false
                    onDimiss?()
                }
            })
    }
}

extension View {
    func presentSheet<Modal: View>(
        isPresented: Binding<Bool>,
        height: CGFloat? = nil,
        onDimiss: (() -> Void)? = nil,
        @ViewBuilder content: @escaping () -> Modal
    ) -> some View {
        modifier(
            ModalTypeView(
                isPresented: isPresented,
                modalHeight: height,
                modal: content,
                onDimiss: onDimiss
            )
        )
    }

    func presentSheetModifier() -> some View {
        modifier(PresentSheetModifier())
    }
}

struct PartialSheetDismissKey: EnvironmentKey {
    static let defaultValue: (() -> Void)? = nil
}

struct EnableDragGestureKey: EnvironmentKey {
    static let defaultValue: ((Bool) -> Void)? = nil
}

extension EnvironmentValues {
    var partialSheetDismiss: (() -> Void)? {
        get { self[PartialSheetDismissKey.self] }
        set { self[PartialSheetDismissKey.self] = newValue }
    }
    var enableDragGesture: ((Bool) -> Void)? {
        get { self[EnableDragGestureKey.self] }
        set { self[EnableDragGestureKey.self] = newValue }
    }
}


extension Binding where Value == Bool {
    func showSheet() {
        withAnimation {
            self.wrappedValue = true
        }
    }
}

private struct PresentSheetModifier: ViewModifier {
    func body(content: Content) -> some View {
        VStack(spacing: 0) {
            Color.colorBorderPrimaryDefault.frame(width: 36, height: 4).cornerRadius(2, corners: .allCorners)
                .padding(.vertical, .md)
            content
        }
        .fixedSize(horizontal: false, vertical: true)
        .background {
            RoundedCorners(lineWidth: 0, tl: 24, tr: 24, bl: 0, br: 0)
                .fill(.colorBaseBackground)
                .ignoresSafeArea()
        }
    }
}
