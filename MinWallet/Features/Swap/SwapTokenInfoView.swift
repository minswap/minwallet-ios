import SwiftUI
import FlowStacks


struct SwapTokenInfoView: View {
    @Environment(\.partialSheetDismiss)
    private var onDismiss
    @ObservedObject
    var viewModel: SwapTokenViewModel
    
    var onShowToolTip: ((_ title: LocalizedStringKey, _ content: LocalizedStringKey) -> Void)?
    var onSwap: (() -> Void)?
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("Details")
                .font(.titleH5)
                .frame(maxWidth: .infinity, alignment: .leading)
                .frame(height: 60)
                .padding(.top, .md)
            HStack {
                DashedUnderlineText(text: viewModel.isSwapExactIn ? "Minimum Received" : "Minimum Send", textColor: .colorInteractiveTentPrimarySub, font: .paragraphSmall)
                Spacer(minLength: 0)
                let tokenName = viewModel.isSwapExactIn ? viewModel.tokenReceive.token.adaName : viewModel.tokenPay.adaName
                let decimal = viewModel.isSwapExactIn ? viewModel.tokenReceive.token.decimals : viewModel.tokenPay.token.decimals
                Text(
                    viewModel.minimumMaximumAmount
                        .toExact(decimal: Double(decimal))
                        .formatNumber(suffix: tokenName, roundingOffset: nil, font: .labelMediumSecondary, fontColor: .colorBaseTent)
                )
                .lineLimit(1)
            }
            .padding(.top, .lg)
            .contentShape(.rect)
            .onTapGesture {
                onShowToolTip?("Minimum received", "Your transaction will revert if there is a large, unfavorable price movement before it is confirmed.You can adjust this by setting percentage of Slippage Tolerance")
            }
            HStack {
                DashedUnderlineText(text: "Slippage Tolerance", textColor: .colorInteractiveTentPrimarySub, font: .paragraphSmall)
                Spacer()
                Text(viewModel.swapSetting.slippageSelectedValue().formatSNumber(maximumFractionDigits: 2) + "%")
                    .font(.labelMediumSecondary)
                    .foregroundStyle(.colorBaseTent)
            }
            .padding(.top, .xl)
            .contentShape(.rect)
            .onTapGesture {
                onShowToolTip?("Slippage tolerance", "Your transaction will revert if the price changes unfavorably by more than this percentage.")
            }
            HStack {
                DashedUnderlineText(text: "Price Impact", textColor: .colorInteractiveTentPrimarySub, font: .paragraphSmall)
                Spacer()
                if let iosTradeEstimate = viewModel.iosTradeEstimate {
                    let priceImpact = iosTradeEstimate.avgPriceImpact
                    let priceImpactColor = iosTradeEstimate.priceImpactColor
                    Text(priceImpact.formatSNumber(maximumFractionDigits: 4) + "%")
                        .font(.labelMediumSecondary)
                        .foregroundStyle(priceImpactColor.0)
                }
            }
            .padding(.top, .xl)
            .contentShape(.rect)
            .onTapGesture {
                onShowToolTip?("Price impact", "This % indicates the potential effect your swap might have on the pool's price. A higher % suggests a more significant impact.")
            }
            HStack {
                DashedUnderlineText(text: "Liquidity Provider Fee", textColor: .colorInteractiveTentPrimarySub, font: .paragraphSmall)
                Spacer()
                let decimal: Int = {
                    viewModel.isSwapExactIn ? viewModel.tokenPay.token.decimals : viewModel.tokenReceive.token.decimals
                }()
                let currentSymbol: String = {
                    viewModel.isSwapExactIn ? viewModel.tokenPay.token.adaName : viewModel.tokenReceive.token.adaName
                }()
                let fee = viewModel.iosTradeEstimate?.totalLpFee.toExact(decimal: decimal) ?? 0
                Text(fee.formatNumber(suffix: currentSymbol, font: .labelMediumSecondary, fontColor: .colorBaseTent))
            }
            .padding(.top, .xl)
            .contentShape(.rect)
            .onTapGesture {
                onShowToolTip?("Liquidity Provider Fee", "The fee paid to liquidity providers for facilitating your trade. This fee is deducted from your input amount and distributed to users who supply assets to the liquidity pool.")
            }
            HStack {
                DashedUnderlineText(text: "Service Fee", textColor: .colorInteractiveTentPrimarySub, font: .paragraphSmall)
                Spacer()
                let fee = viewModel.iosTradeEstimate?.aggregatorFee.toExact(decimal: TokenManager.shared.tokenAda.decimals) ?? 0
                Text(fee.formatNumber(suffix: Currency.ada.prefix, font: .labelMediumSecondary, fontColor: .colorBaseTent))
            }
            .padding(.top, .xl)
            .contentShape(.rect)
            .onTapGesture {
                onShowToolTip?("Service Fee", "The service fee is charged for routing your trade through multiple liquidity sources to find the best price. The fee is calculated as the greater of 0.85₳ or --% of your trade amount.")
            }
            HStack {
                DashedUnderlineText(text: "DEX's Fees", textColor: .colorInteractiveTentPrimarySub, font: .paragraphSmall)
                Spacer()
                let fee = viewModel.iosTradeEstimate?.totalDexFee.toExact(decimal: TokenManager.shared.tokenAda.decimals) ?? 0
                Text(fee.formatNumber(suffix: Currency.ada.prefix, font: .labelMediumSecondary, fontColor: .colorBaseTent))
            }
            .padding(.top, .xl)
            .contentShape(.rect)
            .onTapGesture {
                onShowToolTip?("DEX's Fees", "The DEX fees includes the batcher fee and network fee required to process your transaction on the blockchain. These fees are necessary to ensure your trade is executed and confirmed by the network.")
            }
            HStack {
                DashedUnderlineText(text: "Refundable deposit", textColor: .colorInteractiveTentPrimarySub, font: .paragraphSmall)
                Spacer()
                let fee = viewModel.iosTradeEstimate?.deposits.toExact(decimal: TokenManager.shared.tokenAda.decimals) ?? 0
                Text(fee.formatNumber(suffix: Currency.ada.prefix, font: .labelMediumSecondary, fontColor: .colorBaseTent))
            }
            .padding(.top, .xl)
            .padding(.bottom, 40)
            .contentShape(.rect)
            .onTapGesture {
                onShowToolTip?("Refundable deposit", "This amount of ADA will be held as minimum UTxO ADA and will be returned when your orders are processed or cancelled")
            }
            /*
            HStack {
                DashedUnderlineText(text: "Deposit ADA", textColor: .colorInteractiveTentPrimarySub, font: .paragraphSmall)
                Spacer()
                Text("2 \(Currency.ada.prefix)")
                    .font(.labelMediumSecondary)
                    .foregroundStyle(.colorBaseTent)
            }
            .padding(.top, .xl)
            .padding(.bottom, 40)
            .contentShape(.rect)
            .onTapGesture {
                onShowToolTip?("Deposit ADA", "This amount of ADA will be held as minimum UTxO ADA and will be returned when your orders are processed or cancelled.")
            }
             */
            let combinedBinding = Binding<Bool>(
                get: { viewModel.enableSwap },
                set: { _ in }
            )
            let swapTitle: LocalizedStringKey = viewModel.errorInfo?.content ?? "Swap"
            CustomButton(title: swapTitle, isEnable: combinedBinding) {
                onDismiss?()
                onSwap?()
            }
            .frame(height: 56)
            .padding(.bottom, .md)
        }
        .padding(.horizontal, .xl)
        .presentSheetModifier()
    }
}


#Preview {
    VStack {
        Spacer()
        SwapTokenInfoView(viewModel: SwapTokenViewModel(tokenReceive: nil))
    }
}
