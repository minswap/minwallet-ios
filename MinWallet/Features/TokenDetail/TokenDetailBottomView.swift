import SwiftUI
import FlowStacks


extension TokenDetailView {
    var tokenDetailBottomView: some View {
        ZStack {
            VStack(
                alignment: .leading,
                spacing: .md,
                content: {
                    let tokenByID = tokenManager.tokenById(tokenID: viewModel.token.uniqueID)
                    let amount = tokenByID?.amount ?? 0
                    let valueInAda = (tokenByID?.subPriceValue ?? 0)
                    Text("My balance")
                        .font(.paragraphSmall)
                        .foregroundStyle(.colorInteractiveTentPrimarySub)
                        .padding(.horizontal, .xl)
                        .padding(.top, .xl)
                    HStack(alignment: .bottom) {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(
                                amount.formatNumber(
                                    suffix: "",
                                    roundingOffset: tokenByID?.decimals,
                                    font: .titleH5,
                                    fontColor: .colorBaseTent)
                            )
                            .minimumScaleFactor(0.6)
                            .lineLimit(1)
                            Text(
                                valueInAda.getPriceValue(
                                    appSetting: appSetting,
                                    font: .paragraphSmall,
                                    roundingOffset: appSetting.currency == Currency.ada.rawValue ? 6 : 3,
                                    fontColor: .colorInteractiveTentPrimarySub
                                )
                                .attribute
                            )
                            .minimumScaleFactor(0.6)
                            .lineLimit(1)
                            .padding(.bottom, 2)
                        }
                        Spacer()
                        CustomButton(title: "DeFi Swap", frameType: .wrapContent) {
                            navigator.push(.swapToken(.swapToken(token: viewModel.token)))
                        }
                        .frame(height: 44)
                    }
                    .padding(.horizontal, .xl)
                    .padding(.bottom, .xl)
                })
        }
        .background(.colorBaseBackground)
        .cornerRadius(BorderRadius._3xl)
        .overlay(
            RoundedRectangle(cornerRadius: BorderRadius._3xl).stroke(.colorBorderPrimaryDefault, lineWidth: 1)
        )
        .shadow(color: colorScheme == .light ? .colorBaseTent.opacity(0.18) : .clear, radius: 10, x: 10, y: 10)
        .zIndex(999)
        .compositingGroup()
    }
}

#Preview {
    TokenDetailView(viewModel: TokenDetailViewModel(token: TokenProtocolDefault()))
        .environmentObject(AppSetting.shared)
}
