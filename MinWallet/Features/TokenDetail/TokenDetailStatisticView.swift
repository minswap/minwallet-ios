import SwiftUI


extension TokenDetailView {
    var tokenDetailStatisticView: some View {
        VStack(
            alignment: .leading, spacing: 0,
            content: {
                HStack(alignment: .center, spacing: 4) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("For project, let's increase you visibility by")
                            .font(.paragraphSmall)
                            .foregroundStyle(.colorInteractiveTentSecondarySub)
                        Text("Update token supply")
                            .font(.labelSmallSecondary)
                            .foregroundStyle(.colorInteractiveToneHighlight)
                            .onTapGesture {
                                UIApplication.shared.open(URL(string: "https://github.com/minswap/minswap-tokens")!, options: [:], completionHandler: nil)
                            }
                    }
                    Spacer(minLength: 0)
                    Image(.icArrowUp)
                        .resizable()
                        .renderingMode(.template)
                        .foregroundStyle(.colorInteractiveToneHighlight)
                        .frame(width: 24, height: 24)
                        .onTapGesture {
                            UIApplication.shared.open(URL(string: "https://github.com/minswap/minswap-tokens")!, options: [:], completionHandler: nil)
                        }
                        .offset(y: 1)
                }
                .padding(.horizontal, .xl)
                .padding(.vertical, .lg)
                .background(.colorSurfaceHighlightDefault)
                .cornerRadius(.xl)
                .padding(.bottom, .xl)
                Text("Statistics")
                    .font(.titleH6)
                    .foregroundStyle(.colorBaseTent)
                    .padding(.bottom, .lg)
                HStack {
                    DashedUnderlineText(text: "Avg. price", textColor: .colorInteractiveTentPrimarySub, font: .paragraphSmall)
                    Spacer()
                    let priceValue = (viewModel.topAsset?.price_usd ?? 0).getPriceValue(appSetting: appSetting)
                    Text(priceValue.1)
                        .font(.labelMediumSecondary)
                        .foregroundStyle(.colorBaseTent)
                }
                .frame(height: 40)
                .contentShape(.rect)
                .onTapGesture {
                    title = "Avg. price"
                    content = "The Weighted Arithmetic Mean of all ADA-\(viewModel.token.adaName) pools."
                    $isShowToolTip.showSheet()
                }
                HStack(spacing: 2) {
                    let priceChange24h: Double = viewModel.topAsset?.price_change_24h ?? 0
                    DashedUnderlineText(text: "Avg. price change (24h)", textColor: .colorInteractiveTentPrimarySub, font: .paragraphSmall)
                    Spacer()
                    if priceChange24h != 0 {
                        Text(abs(priceChange24h).formatSNumber(maximumFractionDigits: 2) + "%")
                            .font(.labelSmallSecondary)
                            .foregroundStyle(priceChange24h > 0 ? .colorBaseSuccess : .colorBorderDangerDefault)
                        Image(priceChange24h > 0 ? .icUp : .icDown)
                            .resizable()
                            .frame(width: 16, height: 16)
                    } else {
                        Text("--")
                            .font(.labelSmallSecondary)
                            .foregroundStyle(.colorBaseTent)
                    }
                }
                .frame(height: 40)
                .contentShape(.rect)
                .onTapGesture {
                    title = "Avg. price change (24h)"
                    content = "The price from Weighted Arithmetic Mean of all ADA-\(viewModel.token.adaName) pools."
                    $isShowToolTip.showSheet()
                }
                HStack {
                    DashedUnderlineText(text: "Volume (24h)", textColor: .colorInteractiveTentPrimarySub, font: .paragraphSmall)
                    Spacer()
                    let volume24hValue = (viewModel.topAsset?.volume_usd_24h ?? 0).getPriceValue(appSetting: appSetting)
                    Text(volume24hValue.value > 0 ? volume24hValue.attribute : AttributedString("--"))
                        .font(.labelMediumSecondary)
                        .foregroundStyle(.colorBaseTent)
                }
                .frame(height: 40)
                .contentShape(.rect)
                .onTapGesture {
                    title = "Volume (24h)"
                    content = "Volume (24h) is the amount of the asset that has been traded on Minswap during the past 24 hours."
                    $isShowToolTip.showSheet()
                }
                //if viewModel.token.decimals > 0 {
                HStack {
                    DashedUnderlineText(text: "Decimal", textColor: .colorInteractiveTentPrimarySub, font: .paragraphSmall)
                    Spacer()
                    Text("\(viewModel.token.decimals)")
                        .font(.labelMediumSecondary)
                        .foregroundStyle(.colorBaseTent)
                }
                .frame(height: 40)
                .contentShape(.rect)
                .onTapGesture {
                    title = "Decimal"
                    content = "It refers to the number of digits used after the decimal point for a specific token. It essentially dictates the smallest indivisible unit of that token."
                    $isShowToolTip.showSheet()
                }
                //}
                HStack {
                    DashedUnderlineText(text: "Market cap", textColor: .colorInteractiveTentPrimarySub, font: .paragraphSmall)
                    Spacer()
                    let value = (viewModel.topAsset?.market_cap_usd ?? 0).getPriceValue(appSetting: appSetting, isFormatK: true)
                    Text(value.value > 0 ? value.attribute : AttributedString("--"))
                        .font(.labelMediumSecondary)
                        .foregroundStyle(.colorBaseTent)
                }
                .frame(height: 40)
                .contentShape(.rect)
                .onTapGesture {
                    title = "Market cap"
                    content = "Market Cap = Current Price x Circulating Supply."
                    $isShowToolTip.showSheet()
                }
                HStack {
                    DashedUnderlineText(text: "Fd Market cap", textColor: .colorInteractiveTentPrimarySub, font: .paragraphSmall)
                    Spacer()
                    let value = (viewModel.topAsset?.fully_diluted_usd ?? 0).getPriceValue(appSetting: appSetting, isFormatK: true)
                    Text(value.value > 0 ? value.attribute : AttributedString("--"))
                        .font(.labelMediumSecondary)
                        .foregroundStyle(.colorBaseTent)
                }
                .frame(height: 40)
                .contentShape(.rect)
                .onTapGesture {
                    title = "Fd Market cap"
                    content = "The market cap if the total supply was in circulation. Fully Diluted Market Cap = Current Price x Total Supply."
                    $isShowToolTip.showSheet()
                }
                HStack {
                    DashedUnderlineText(text: "Circulating supply", textColor: .colorInteractiveTentPrimarySub, font: .paragraphSmall)
                    Spacer()
                    let value = (viewModel.topAsset?.circulating_supply ?? 0).getPriceValue(appSetting: appSetting, isFormatK: true)
                    Text(value.value > 0 ? value.attribute : AttributedString("--"))
                        .font(.labelMediumSecondary)
                        .foregroundStyle(.colorBaseTent)
                }
                .frame(height: 40)
                .contentShape(.rect)
                .onTapGesture {
                    title = "Circulating supply"
                    content = "The number of coins circulating in the market and available to the public for trading, similar to publicly traded shares on the stock market."
                    $isShowToolTip.showSheet()
                }
                HStack {
                    DashedUnderlineText(text: "Total supply", textColor: .colorInteractiveTentPrimarySub, font: .paragraphSmall)
                    Spacer()
                    let value = (viewModel.topAsset?.total_supply ?? 0).getPriceValue(appSetting: appSetting, isFormatK: true)
                    Text(value.value > 0 ? value.attribute : AttributedString("--"))
                        .font(.labelMediumSecondary)
                        .foregroundStyle(.colorBaseTent)
                }
                .frame(height: 40)
                .padding(.bottom, .xl)
                .contentShape(.rect)
                .onTapGesture {
                    title = "Total supply"
                    content = "Total supply = Total coins created - coins that have been burned (if any) It is comparable to outstanding shares in the market."
                    $isShowToolTip.showSheet()
                }
                Text("About \(viewModel.token.adaName) (\(viewModel.token.projectName.isBlank ? viewModel.token.adaName : viewModel.token.projectName))")
                    .font(.titleH6)
                    .foregroundStyle(.colorBaseTent)
                    .padding(.bottom, .lg)
                if !viewModel.token.category.isEmpty {
                    FlexibleView(
                        data: viewModel.token.category,
                        spacing: .xs,
                        alignment: .leading
                    ) { item in
                        Text(verbatim: item)
                            .font(.paragraphXSmall)
                            .foregroundStyle(.colorInteractiveTentPrimarySub)
                            .padding(.horizontal, .lg)
                            .frame(height: 24)
                            .background(RoundedRectangle(cornerRadius: 12).fill(.colorSurfacePrimaryDefault))
                    }
                    .padding(.bottom, .xl)
                }
                if viewModel.isSuspiciousToken {
                    HStack(spacing: Spacing.md) {
                        Image(.icWarning)
                            .resizable()
                            .frame(width: 16, height: 16)
                        Text("Scam token")
                            .font(.paragraphXSmall)
                            .foregroundStyle(.colorInteractiveToneDanger)
                    }
                    .padding(.md)
                    .background(
                        RoundedRectangle(cornerRadius: 8).fill(.colorInteractiveToneDanger8)
                    )
                    .frame(height: 32)
                    .padding(.bottom, .xl)
                }
                if !viewModel.token.isVerified {
                    HStack(spacing: Spacing.md) {
                        Image(.icWarningYellow)
                            .resizable()
                            .frame(width: 16, height: 16)
                        Text("This token has not been verified yet. Please ensure the correct policyId")
                            .font(.paragraphXSmall)
                            .foregroundStyle(.colorInteractiveToneWarning)
                            .lineLimit(nil)
                    }
                    .padding(.md)
                    .background(
                        RoundedRectangle(cornerRadius: 8).fill(.colorSurfaceWarningDefault)
                    )
                    .frame(minHeight: 32)
                    .padding(.bottom, .xl)
                }
                if let description = viewModel.topAsset?.asset.metadata?.description, !description.isBlank {
                    Text(description)
                        .lineLimit(nil)
                        .font(.paragraphSmall)
                        .foregroundStyle(.colorBaseTent)
                        .padding(.bottom, .xl)
                }
                if !viewModel.token.tokenName.isEmpty {
                    HStack(spacing: 4) {
                        Text("Token name")
                            .foregroundStyle(.colorInteractiveTentPrimarySub)
                            .font(.paragraphSmall)
                        Spacer()
                        Text(viewModel.token.tokenName)
                            .font(.labelMediumSecondary)
                            .foregroundStyle(isCopiedTokenName ? .colorBaseSuccess : .colorBaseTent)
                            .lineLimit(1)
                        if isCopiedTokenName {
                            Image(.icCheckMark)
                                .resizable()
                                .renderingMode(.template)
                                .foregroundStyle(.colorBaseSuccess)
                                .frame(width: 16, height: 16)
                        } else {
                            Image(.icCopySeedPhrase)
                                .resizable()
                                .renderingMode(.template)
                                .foregroundStyle(.colorInteractiveTentPrimarySub)
                                .frame(width: 16, height: 16)
                        }
                    }
                    .frame(height: 40)
                    .containerShape(.rect)
                    .onTapGesture {
                        UIPasteboard.general.string = viewModel.token.tokenName
                        withAnimation {
                            isCopiedTokenName = true
                        }
                        DispatchQueue.main.asyncAfter(
                            deadline: .now() + .seconds(2),
                            execute: {
                                withAnimation {
                                    self.isCopiedTokenName = false
                                }
                            })
                    }
                }
                HStack(spacing: 4) {
                    Text("Policy ID")
                        .foregroundStyle(.colorInteractiveTentPrimarySub)
                        .font(.paragraphSmall)
                    Spacer()
                    Text(viewModel.token.currencySymbol.shortenAddress)
                        .font(.labelMediumSecondary)
                        .foregroundStyle(isCopiedPolicy ? .colorBaseSuccess : .colorBaseTent)
                        .lineLimit(1)
                    if isCopiedPolicy {
                        Image(.icCheckMark)
                            .resizable()
                            .renderingMode(.template)
                            .foregroundStyle(.colorBaseSuccess)
                            .frame(width: 16, height: 16)
                    } else {
                        Image(.icCopySeedPhrase)
                            .resizable()
                            .renderingMode(.template)
                            .foregroundStyle(.colorInteractiveTentPrimarySub)
                            .frame(width: 16, height: 16)
                    }
                }
                .frame(height: 40)
                .containerShape(.rect)
                .onTapGesture {
                    UIPasteboard.general.string = viewModel.token.currencySymbol
                    withAnimation {
                        isCopiedPolicy = true
                    }
                    DispatchQueue.main.asyncAfter(
                        deadline: .now() + .seconds(2),
                        execute: {
                            withAnimation {
                                self.isCopiedPolicy = false
                            }
                        })
                }
                HStack(spacing: 4) {
                    DashedUnderlineText(text: "Risk score", textColor: .colorInteractiveTentPrimarySub, font: .paragraphSmall)
                    Spacer()
                    if let riskScoreOfAsset = viewModel.riskCategory,
                        let riskCategory = riskScoreOfAsset.riskCategory.value
                    {
                        Text(riskCategory.rawValue.uppercased())
                            .font(.paragraphXSemiSmall)
                            .foregroundStyle(riskCategory.textColor)
                            .padding(.horizontal, .lg)
                            .frame(height: 24)
                            .background(
                                RoundedRectangle(cornerRadius: BorderRadius.full).fill(riskCategory.backgroundColor)
                            )
                            .containerShape(.rect)
                            .onTapGesture {
                                let url = "https://app.xerberus.io/cardano/stats?token=\(riskScoreOfAsset.assetName)"
                                url.openURL()
                            }
                    } else {
                        Text("Uncalibrated")
                            .font(.paragraphXSemiSmall)
                            .foregroundStyle(.colorBaseTent)
                            .padding(.horizontal, .lg)
                            .frame(height: 24)
                            .background(
                                RoundedRectangle(cornerRadius: BorderRadius.full).fill(.colorSurfacePrimarySub)
                            )
                    }
                }
                .frame(height: 40)
                .contentShape(.rect)
                .onTapGesture {
                    title = "Risk score"
                    content = "Powered by Xerberus. This is for informational purposes only and is not intended to be used as financial advice. User Agreement"
                    $isShowToolTip.showSheet()
                }
                Text("External links")
                    .font(.labelSemiSecondary)
                    .foregroundStyle(.colorBaseTent)
                    .frame(height: 28)
                    .padding(.top, .xl)
                let socialLinks = viewModel.topAsset?.socialLinks ?? [:]
                let keys = socialLinks.map { $0.key }.sorted { $0.order < $1.order }
                if !socialLinks.isEmpty {
                    FlexibleView(
                        data: keys,
                        spacing: 0,
                        alignment: .leading
                    ) { key in
                        Image(key.image)
                            .resizable()
                            .frame(width: 32, height: 32)
                            .onTapGesture {
                                guard let link = socialLinks[key],
                                    let url = URL(string: link)
                                else { return }
                                UIApplication.shared.open(url, options: [:], completionHandler: nil)
                            }
                    }
                    .padding(.top, .md)
                    .padding(.bottom, .xl)
                } else {
                    Image(.icCardano)
                        .resizable()
                        .frame(width: 20, height: 20)
                        .padding(.top, .md)
                        .padding(.bottom, .xl)
                        .onTapGesture {
                            guard let url = URL(string: MinWalletConstant.transactionURL + "/\(viewModel.token.currencySymbol)" + "\(viewModel.token.tokenName)")
                            else { return }
                            UIApplication.shared.open(url, options: [:], completionHandler: nil)
                        }
                }
            })
    }
}

#Preview {
    ScrollView {
        TokenDetailView(viewModel: TokenDetailViewModel(token: TokenProtocolDefault()))
            .environmentObject(AppSetting.shared)
    }
}
