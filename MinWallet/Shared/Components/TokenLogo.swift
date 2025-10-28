import SwiftUI


struct TokenLogoView: View {
    private static let TOKEN_IMAGE_DEFAULT: [String: ImageResource] = [
        MinWalletConstant.adaToken: .ada,
        MinWalletConstant.minToken: .min,
        MinWalletConstant.mintToken: .mint,
    ]

    @Binding
    private var currencySymbol: String?
    @Binding
    private var tokenName: String?
    @Binding
    private var isVerified: Bool?
    @State
    private var size: CGSize = .init(width: 28, height: 28)
    @Binding
    private var forceVerified: Bool
    @Binding
    private var isFav: Bool?

    init(
        currencySymbol: String? = nil,
        tokenName: String? = nil,
        isVerified: Bool? = nil,
        forceVerified: Bool = false,
        isFav: Bool = false,
        size: CGSize = .init(width: 28, height: 28)
    ) {
        self._currencySymbol = .constant(currencySymbol)
        self._tokenName = .constant(tokenName)
        self._isVerified = .constant(isVerified)
        self._forceVerified = .constant(forceVerified)
        self._isFav = .constant(isFav)
        self._size = .init(initialValue: size)
    }

    private var uniqueID: String {
        let currencySymbol = currencySymbol ?? ""
        let tokenName = tokenName ?? ""
        if currencySymbol.isEmpty && tokenName.isEmpty {
            return ""
        }

        if currencySymbol.isEmpty {
            return tokenName
        }

        if tokenName.isEmpty {
            return currencySymbol
        }
        return currencySymbol + "." + tokenName
    }

    var body: some View {
        ZStack {
            Group {
                if let image = Self.TOKEN_IMAGE_DEFAULT[uniqueID] {
                    Image(image)
                        .resizable()
                        .scaledToFit()
                } else if uniqueID.isEmpty {
                    Image(.ada)
                        .resizable()
                        .scaledToFit()
                } else {
                    CustomWebImage(url: buildImageURL(currencySymbol: currencySymbol ?? "", tokenName: tokenName ?? ""), frameSize: size)
                }
            }
            .frame(width: size.width, height: size.height)
            .clipShape(Circle())
            if (isVerified == true || (Self.TOKEN_IMAGE_DEFAULT[uniqueID] != nil && !forceVerified) || isFav == true) {
                Circle()
                    .fill(.colorBaseBackground)
                    .frame(width: size.width * 16 / 28, height: size.width * 16 / 28)
                    .overlay(
                        Image(isFav == true ? .icFavHome : .icVerifiedBadge)
                            .resizable()
                            .frame(width: size.width * 12 / 28, height: size.width * 12 / 28)
                    )
                    .overlay(
                        Circle()
                            .stroke(.colorSurfacePrimarySub, lineWidth: 1)
                    )
                    .position(x: size.width - 2, y: size.width - 2)
            }
        }
        .frame(width: size.width, height: size.height)
    }

    private func buildImageURL(currencySymbol: String, tokenName: String) -> String {
        let path = "\(currencySymbol)\(tokenName)"
        return "\(MinWalletConstant.minAssetURL)/\(path)"
    }
}

#Preview {
    VStack {
        TokenLogoView(currencySymbol: "", tokenName: "", isVerified: true, size: .init(width: 24, height: 24))
        //            .frame(width: 28, height: 28)
    }
    .background(.pink)

}


struct HalfCircleMask: Shape {
    let isLeft: Bool

    func path(in rect: CGRect) -> Path {
        var path = Path()
        let center = CGPoint(x: rect.midX, y: rect.midY)
        let radius = min(rect.width, rect.height) / 2

        if isLeft {
            path.addArc(
                center: center,
                radius: radius,
                startAngle: .degrees(90),
                endAngle: .degrees(270),
                clockwise: true)
        } else {
            path.addArc(
                center: center,
                radius: radius,
                startAngle: .degrees(270),
                endAngle: .degrees(90),
                clockwise: true)
        }
        path.addLine(to: center)
        path.closeSubpath()

        return path
    }
}
