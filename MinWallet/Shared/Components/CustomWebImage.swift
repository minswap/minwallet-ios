import SwiftUI
import SDWebImageSwiftUI


struct CustomWebImage<Placeholder: View>: View {
    let url: String?
    let frameSize: CGSize?
    let placeholder: () -> Placeholder
    
    init(
        url: String?,
        frameSize: CGSize? = nil,
        @ViewBuilder placeholder: @escaping () -> Placeholder = {
            Image(.ada)
                .resizable()
                .scaledToFit()
                .clipped()
        }
    ) {
        self.url = url
        self.frameSize = frameSize
        self.placeholder = placeholder
    }
    
    var body: some View {
        if let frameSize = frameSize {
            WebImage(url: URL(string: url ?? "")) { image in
                image
                    .centerCropped()
            } placeholder: {
                placeholder()
            }
            .indicator(.activity)  // Show loading activity indicator
            .transition(.fade(duration: 0.5))  // Smooth fade transition
            .frame(width: frameSize.width, height: frameSize.height)
            .clipped()
        } else {
            WebImage(url: URL(string: url ?? "")) { image in
                image
                    .centerCropped()
            } placeholder: {
                placeholder()
            }
            .indicator(.activity)
            .transition(.fade(duration: 0.5))  // Smooth fade transition
            .aspectRatio(1, contentMode: .fit)
            .frame(maxWidth: .infinity)
            .clipped()
        }
    }
}

private extension Image {
    func centerCropped() -> some View {
        GeometryReader { geo in
            self
                .resizable()
                .scaledToFill()
                .frame(width: geo.size.width, height: geo.size.height)
                .clipped()
                .contentShape(Rectangle())
        }
    }
}
