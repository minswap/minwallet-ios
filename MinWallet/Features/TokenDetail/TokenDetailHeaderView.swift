import SwiftUI
import FlowStacks


extension TokenDetailView {
    var smallHeader: some View {
        HStack(alignment: .center, spacing: 12) {
            Button(
                action: {
                    navigator.pop()
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
            let offset = viewModel.scrollOffset.y
            let heightOrders = viewModel.sizeOfLargeHeader.height
            let opacity = abs(max(0, min(1, (offset - heightOrders / 2) / (heightOrders / 2))))
            
            HStack(alignment: .center, spacing: 12) {
                TokenLogoView(currencySymbol: viewModel.token.currencySymbol, tokenName: viewModel.token.tokenName, isVerified: viewModel.token.isVerified, size: .init(width: 24, height: 24))
                VStack(alignment: .leading, spacing: 2) {
                    Text(viewModel.token.adaName)
                        .lineLimit(1)
                        .foregroundStyle(.colorBaseTent)
                        .font(.labelMediumSecondary)
                    let chartSelected =
                        viewModel.chartDataSelected?.value
                        .formatNumber(
                            prefix: Currency.usd.prefix,
                            font: .paragraphXSmall,
                            fontColor: .colorInteractiveTentPrimarySub) ?? "--"
                    HStack(alignment: .firstTextBaseline, spacing: 4) {
                        Text(chartSelected)
                        HStack(alignment: .center, spacing: 4) {
                            if !viewModel.percent.isZero {
                                Circle().frame(width: 2, height: 2).background(.colorInteractiveTentPrimarySub)
                                Text("\(abs(viewModel.percent).formatSNumber(maximumFractionDigits: 2))%")
                                    .font(.paragraphXSmall)
                                    .foregroundStyle(viewModel.percent > 0 ? .colorBaseSuccess : .colorBorderDangerDefault)
                                Image(viewModel.percent > 0 ? .icUp : .icDown)
                                    .resizable()
                                    .frame(width: 16, height: 16)
                            }
                        }
                    }
                    .frame(height: 22)
                }
                .animation(.default, value: viewModel.chartDatas)
            }
            .opacity((viewModel.sizeOfLargeHeader.height / 2 - offset) < 0 ? (opacity) : 0)
            Spacer()
            Image(viewModel.isFav ? .icSavedFav : .icFavourite)
                .fixSize(40)
                .onTapGesture {
                    viewModel.isFav.toggle()
                    userInfo.tokenFavSelected(token: viewModel.token, isAdd: viewModel.isFav)
                }
        }
        .background(.colorBaseBackground)
        .padding(.horizontal, .xl)
    }
    
    var largeHeader: some View {
        VStack(alignment: .leading, spacing: 0) {
            Color.clear.frame(height: .md)
            HStack(
                alignment: .center,
                content: {
                    TokenLogoView(currencySymbol: viewModel.token.currencySymbol, tokenName: viewModel.token.tokenName, isVerified: viewModel.token.isVerified, size: .init(width: 24, height: 24))
                    HStack(
                        alignment: .firstTextBaseline, spacing: 4,
                        content: {
                            Text(viewModel.token.adaName)
                                .foregroundStyle(.colorBaseTent)
                                .lineLimit(1)
                                .font(.labelMediumSecondary)
                            Text(viewModel.token.projectName.isBlank ? viewModel.token.adaName : viewModel.token.projectName)
                                .foregroundStyle(.colorInteractiveTentPrimarySub)
                                .lineLimit(1)
                                .font(.labelMediumSecondary)
                        })
                    Spacer()
                })
            let chartSelected =
                viewModel.chartDataSelected?.value
                .formatNumber(
                    prefix: Currency.usd.prefix,
                    font: .titleH4,
                    fontColor: .colorBaseTent) ?? "-"
            
            Text(chartSelected)
                .padding(.top, .lg)
                .padding(.bottom, .xs)
                .frame(height: 55)
            HStack(spacing: 4) {
                /*
                let value: Double? = {
                    guard let value = viewModel.chartDataSelected?.value else { return nil }
                    return value * appSetting.currencyInADA
                }()
                if let value = value {
                    Text(
                        value.formatNumber(
                            prefix: appSetting.currency == Currency.usd.rawValue ? Currency.usd.prefix : "",
                            font: .titleH7,
                            fontColor: .colorBaseTent)
                    )
                    .padding(.horizontal, .xs)
                }
                 */
                if !viewModel.percent.isZero {
                    Text("\(abs(viewModel.percent).formatSNumber(maximumFractionDigits: 2))%")
                        .font(.labelSmallSecondary)
                        .foregroundStyle(viewModel.percent > 0 ? .colorBaseSuccess : .colorBorderDangerDefault)
                    Image(viewModel.percent > 0 ? .icUp : .icDown)
                        .resizable()
                        .frame(width: 16, height: 16)
                }
            }
            .frame(height: 20)
            .padding(.bottom, .xs)
        }
        .padding(.horizontal, .xl)
        .animation(.default, value: viewModel.chartDatas)
    }
}


#Preview {
    TokenDetailView(viewModel: TokenDetailViewModel(token: TokenProtocolDefault()))
        .environmentObject(AppSetting.shared)
}
