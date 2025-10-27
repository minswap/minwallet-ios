import SwiftUI


struct PopupSheetModifier<SheetContent: View>: ViewModifier {
    @Binding
    var isPresented: Bool
    @State
    private var sheetHeight: CGFloat = .zero
    
    let onDismiss: (() -> Void)?
    let content: () -> SheetContent
    
    func body(content: Content) -> some View {
        content
            .sheet(isPresented: $isPresented, onDismiss: onDismiss) {
                self.content()
                    .background(
                        GeometryReader { geo in
                            Color.clear
                                .preference(key: SizePreferenceKey.self, value: geo.size)
                        }
                    )
                    .onPreferenceChange(SizePreferenceKey.self) { newSize in
                        sheetHeight = newSize.height
                    }
                    .presentationDetents([.height(sheetHeight)])
                    .presentationDragIndicator(.visible)
            }
    }
}

extension View {
    func popupSheet<SheetContent: View>(
        isPresented: Binding<Bool>,
        onDismiss: (() -> Void)? = nil,
        @ViewBuilder content: @escaping () -> SheetContent
    ) -> some View {
        self.modifier(PopupSheetModifier(isPresented: isPresented, onDismiss: onDismiss, content: content))
    }
}
