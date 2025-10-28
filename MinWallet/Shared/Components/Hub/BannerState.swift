import SwiftUI


class BannerState: ObservableObject {
    @Published
    var isShowingBanner: Bool = false

    @Published
    var infoContent: (() -> AnyView)?

    init() {}

    func infoContentDefault(onViewTransaction: (() -> Void)?) -> AnyView {
        AnyView(
            HStack(alignment: .top) {
                Image(.icCheckSuccess)
                    .fixSize(24)
                VStack(alignment: .leading, spacing: 4) {
                    Text("Transaction Submitted")
                        .font(.labelSmallSecondary)
                        .foregroundStyle(.colorInteractiveToneSuccess)
                    Text("Your transaction has been submitted successfully")
                        .lineLimit(nil)
                        .font(.paragraphSmall)
                        .foregroundStyle(.colorInteractiveTentPrimarySub)
                    HStack(spacing: 4) {
                        Text("View on explorer")
                            .underline()
                            .baselineOffset(4)
                            .font(.labelSmallSecondary)
                            .foregroundStyle(.colorInteractiveTentSecondaryDefault)
                            .onTapGesture {
                                onViewTransaction?()
                            }
                        Image(.icArrowUp)
                            .fixSize(.xl)
                            .onTapGesture {
                                onViewTransaction?()
                            }
                    }
                    .padding(.top, 4)
                }
                Spacer(minLength: 0)
            }
            .padding()
            .background(.colorBaseBackground)
            .clipped()
            .cornerRadius(._3xl)
            .overlay(RoundedRectangle(cornerRadius: ._3xl).stroke(.colorBaseSuccessSub, lineWidth: 1))
            .shadow(radius: 5, x: 0, y: 5)
        )
    }

    private func errorDefault(_ error: String) -> AnyView {
        AnyView(
            HStack(alignment: .centerIconAlignment) {
                Image(.icCloseToast)
                    .fixSize(24)
                    .alignmentGuide(.centerIconAlignment) { d in d[VerticalAlignment.center] }
                VStack(alignment: .leading, spacing: 4) {
                    Text("Error")
                        .font(.labelSmallSecondary)
                        .foregroundStyle(.colorInteractiveToneDanger)
                        .alignmentGuide(.centerIconAlignment) { d in d[VerticalAlignment.center] }
                    Text(error)
                        .lineLimit(nil)
                        .font(.paragraphSmall)
                        .foregroundStyle(.colorInteractiveTentPrimarySub)
                }
                Spacer(minLength: 0)
                Image(.icClose)
                    .fixSize(24)
                    .alignmentGuide(.centerIconAlignment) { d in d[VerticalAlignment.center] }
                    .onTapGesture {
                        withAnimation {
                            self.isShowingBanner = false
                        }
                    }
            }
            .padding()
            .background(.colorBaseBackground)
            .clipped()
            .cornerRadius(.lg)
            .overlay(RoundedRectangle(cornerRadius: .lg).stroke(.colorBorderDangerSub, lineWidth: 1))
            .shadow(color: Color(.sRGBLinear, white: 0, opacity: 0.15), radius: 5, x: 0, y: 5)
        )
    }

    func showBanner(isShow: Bool) {
        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(250)) {
            withAnimation {
                self.isShowingBanner = isShow
            }
        }
    }

    func showBannerError(_ error: String) {
        self.infoContent = { [weak self] in
            guard let self = self else { return AnyView(Text("")) }
            return self.errorDefault(error)
        }
        self.showBanner(isShow: true)
    }
}


private extension VerticalAlignment {
    struct CenterIconAlignment: AlignmentID {
        static func defaultValue(in context: ViewDimensions) -> CGFloat {
            context[.top]
        }
    }

    static let centerIconAlignment = VerticalAlignment(CenterIconAlignment.self)
}
