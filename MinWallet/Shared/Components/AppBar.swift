import SwiftUI


struct BaseContentView: ViewModifier {
    var screenTitle: String = ""
    var titleView: (() -> AnyView)?
    var backgroundColor: Color = .colorBaseBackground
    var actionBarHeight: CGFloat = 48

    var iconRight: ImageResource?
    var alignmentTitle: Alignment = .leading
    var actionLeft: (() -> Void)?
    var actionRight: (() -> Void)?
    var ignoreSafeArea: Bool = false

    func body(content: Content) -> some View {
        ZStack {
            Color.colorBaseBackground.ignoresSafeArea()
            VStack(
                spacing: 0,
                content: {
                    HStack(spacing: .lg) {
                        if let actionLeft = actionLeft {
                            Button(
                                action: {
                                    actionLeft()
                                },
                                label: {
                                    Image(.icBack)
                                        .resizable()
                                        .frame(width: ._3xl, height: ._3xl)
                                        .padding(.md)
                                        .background(RoundedRectangle(cornerRadius: BorderRadius.full).stroke(.colorBorderPrimaryTer, lineWidth: 1))
                                }
                            )
                            .buttonStyle(.plain)
                        }

                        if let titleView = titleView {
                            if alignmentTitle != .leading {
                                Spacer()
                            }
                            titleView()
                            if alignmentTitle != .trailing {
                                Spacer()
                            }
                        }
                        if !screenTitle.isEmpty {
                            if alignmentTitle != .leading {
                                Spacer()
                            }
                            Text(screenTitle)
                                .lineLimit(1)
                                .font(.labelMediumSecondary)
                                .foregroundStyle(.colorBaseTent)
                            if alignmentTitle != .trailing {
                                Spacer()
                            }
                        }

                        if let actionRight = actionRight, let iconRight = iconRight {
                            Button(
                                action: {
                                    actionRight()
                                },
                                label: {
                                    Image(iconRight)
                                        .resizable()
                                        .frame(width: 40, height: 40)
                                }
                            )
                            .buttonStyle(.plain)
                        }
                    }
                    .frame(height: 48)
                    .padding(.horizontal, .xl)
                    if !ignoreSafeArea {
                        content
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                            .safeAreaInset(edge: .bottom) {
                                Color.clear.frame(height: 0)
                            }
                    } else {
                        content
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                            .ignoresSafeArea()
                    }
                })
        }
    }

    static func text() -> some View { Text("zzz") }
}

#Preview {
    VStack {
        Text("zzz")
        Spacer()
    }
    .modifier(
        BaseContentView(
            titleView: {
                AnyView(
                    VStack {
                        BaseContentView.text()
                    }
                )
            },
            iconRight: .icFavourite,
            actionLeft: {

            },
            actionRight: {

            }))
}
