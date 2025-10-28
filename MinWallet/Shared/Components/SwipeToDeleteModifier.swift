import SwiftUI


struct SwipeToDeleteModifier: ViewModifier {
    @Binding var offset: CGFloat
    @Binding var isDeleted: Bool
    @Binding var enableDrag: Bool
    @GestureState private var isDragging = false

    @Binding
    var height: CGFloat

    @State
    var image: ImageResource = .icDelete

    let onDelete: () -> Void

    @State
    private var isAppear: Bool = false
    @State
    private var isHorizontalDrag = false

    private var dragGesture: some Gesture {
        DragGesture(minimumDistance: 16)
            .updating($isDragging) { _, state, _ in
                state = true
            }
            .onChanged { gesture in
                // Lock to horizontal drag
                if !isHorizontalDrag {
                    isHorizontalDrag = abs(gesture.translation.width) > abs(gesture.translation.height)
                }
                if isHorizontalDrag {
                    offset = max(min(gesture.translation.width, 0), -68)
                }
            }
            .onEnded { gesture in
                if isHorizontalDrag {
                    withAnimation {
                        offset = gesture.translation.width < -30 ? -68 : 0
                    }
                }
                isHorizontalDrag = false
            }
    }

    func body(content: Content) -> some View {
        GeometryReader { geometry in
            ZStack {
                if isAppear {
                    HStack {
                        Spacer()
                        Image(image)
                            .resizable()
                            .frame(width: image == .icDelete ? 20 : 36, height: image == .icDelete ? 20 : 36)
                            .padding(.trailing, image == .icDelete ? ._3xl : .xl)
                            .onTapGesture {
                                onDelete()
                            }
                    }
                    .frame(height: geometry.size.height - 4)
                    .background(offset == 0 ? .clear : Color.colorInteractiveDangerDefault)
                }
                content
                    .background(.colorBaseBackground)
                    .cornerRadius(offset < 0 ? 12 : 0, corners: [.topRight, .bottomRight])
                    .shadow(color: offset < 0 ? .colorBaseTent.opacity(0.18) : .clear, radius: 4, x: 2, y: 4)
                    .offset(x: offset)
                    .simultaneousGesture(enableDrag ? dragGesture : nil)
            }
            .opacity(isDeleted ? 0 : 1)
            //.animation(.easeInOut(duration: 0.2), value: offset)
        }
        .frame(height: height)
        .onFirstAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(500)) {
                isAppear = true
            }
        }
    }
}

extension View {
    func swipeToDelete(
        offset: Binding<CGFloat>,
        isDeleted: Binding<Bool>,
        height: CGFloat,
        image: ImageResource = .icDelete,
        onDelete: @escaping () -> Void
    ) -> some View {
        modifier(
            SwipeToDeleteModifier(
                offset: offset,
                isDeleted: isDeleted,
                enableDrag: .constant(true),
                height: .constant(height),
                image: image,
                onDelete: onDelete
            )
        )
    }
    func swipeToDelete(
        offset: Binding<CGFloat>,
        isDeleted: Binding<Bool>,
        enableDrag: Binding<Bool>,
        height: Binding<CGFloat>,
        image: ImageResource = .icDelete,
        onDelete: @escaping () -> Void
    ) -> some View {
        modifier(SwipeToDeleteModifier(offset: offset, isDeleted: isDeleted, enableDrag: enableDrag, height: height, image: image, onDelete: onDelete))
    }
}

#Preview(body: {
    SearchTokenView()
})
