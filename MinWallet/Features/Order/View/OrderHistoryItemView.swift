import SwiftUI


struct OrderHistoryItemView: View {
    @State
    var wrapOrder: WrapOrderHistory? = .init()
    @State
    var order: OrderHistory?

    var onCancelItem: (() -> Void)?

    var body: some View {
        VStack(spacing: 0) {
            tokenView
                .frame(minHeight: 40)
                .padding(.top, .md)
            HStack(alignment: .top, spacing: 0) {
                Text("You paid")
                    .font(.paragraphSmall)
                    .foregroundStyle(.colorInteractiveTentPrimarySub)
                    .padding(.trailing, .xs)
                Spacer()
                let inputs = wrapOrder?.inputAsset ?? []
                VStack(alignment: .trailing, spacing: 4) {
                    ForEach(inputs, id: \.self) { input in
                        Text(
                            input.amount
                                .formatNumber(
                                    suffix: input.currency,
                                    roundingOffset: input.decimals,
                                    font: .labelSmallSecondary,
                                    fontColor: .colorBaseTent)
                        )
                        .lineLimit(1)
                        .minimumScaleFactor(0.1)
                        .frame(height: 20)
                    }
                }
                if let percent = wrapOrder?.percent, percent > 0 {
                    Text(" · \(percent.formatSNumber(maximumFractionDigits: 2))%")
                        .font(.labelSmallSecondary)
                        .foregroundStyle(.colorInteractiveToneHighlight)
                        .lineLimit(1)
                        .minimumScaleFactor(0.1)
                }
            }
            .frame(minHeight: 36)
            HStack(alignment: .top) {
                Text("You receive")
                    .font(.paragraphSmall)
                    .foregroundStyle(.colorInteractiveTentPrimarySub)
                Spacer()
                if let wrapOrder = wrapOrder {
                    if wrapOrder.orders.allSatisfy({ $0.status != .batched }) {
                        Text("--")
                            .font(.labelSmallSecondary)
                            .foregroundStyle(.colorBaseTent)
                            .lineLimit(1)
                            .minimumScaleFactor(0.1)
                    } else {
                        let outputs = wrapOrder.outputAsset.filter { $0.amount > 0 }
                        if !outputs.isEmpty {
                            VStack(alignment: .trailing, spacing: 4) {
                                ForEach(outputs, id: \.self) { output in
                                    Text(
                                        output.amount
                                            .formatNumber(
                                                suffix: output.currency,
                                                roundingOffset: output.decimals,
                                                font: .labelSmallSecondary,
                                                fontColor: .colorBaseTent
                                            )
                                    )
                                    .lineLimit(1)
                                    .minimumScaleFactor(0.1)
                                    .frame(height: 20)
                                }
                            }
                        }
                    }
                }
            }
            .frame(minHeight: 36)
            HStack {
                Text("Status")
                    .font(.paragraphSmall)
                    .foregroundStyle(.colorInteractiveTentPrimarySub)
                Spacer()
                HStack(spacing: 4) {
                    Circle().frame(width: 4, height: 4)
                        .foregroundStyle(wrapOrder?.status.foregroundCircleColor ?? .clear)
                    Text(wrapOrder?.status.title)
                        .font(.paragraphXMediumSmall)
                        .foregroundStyle(wrapOrder?.status.foregroundColor ?? .colorInteractiveToneHighlight)
                }
                .padding(.horizontal, .lg)
                .padding(.vertical, .xs)
                .background(
                    RoundedRectangle(cornerRadius: BorderRadius.full).fill(wrapOrder?.status.backgroundColor ?? .colorSurfaceHighlightDefault)
                )
                .frame(height: 20)
                .lineLimit(1)
            }
            .frame(height: 40)
            .padding(.bottom, 9)
            Color.colorBorderPrimarySub.frame(height: 1)
        }
    }

    private var tokenView: some View {
        HStack(spacing: .xs) {
            let inputs = wrapOrder?.inputAsset ?? []
            if inputs.count == 1 {
                TokenLogoView(
                    currencySymbol: inputs.first?.currencySymbol,
                    tokenName: inputs.first?.tokenName,
                    isVerified: inputs.first?.isVerified,
                    size: .init(width: 24, height: 24)
                )
            } else if let first = inputs.first, let last = inputs.last {
                ZStack {
                    TokenLogoView(
                        currencySymbol: first.currencySymbol,
                        tokenName: first.tokenName,
                        isVerified: false,
                        forceVerified: true,
                        size: .init(width: 24, height: 24)
                    )
                    .mask {
                        HalfCircleMask(isLeft: true)
                    }
                    TokenLogoView(
                        currencySymbol: last.currencySymbol,
                        tokenName: last.tokenName,
                        isVerified: false,
                        forceVerified: true,
                        size: .init(width: 24, height: 24)
                    )
                    .mask {
                        HalfCircleMask(isLeft: false)
                    }
                }
            }
            Image(.icBack)
                .resizable()
                .rotationEffect(.degrees(180))
                .frame(width: 16, height: 16)
                .padding(.horizontal, 2)
            let outputs = wrapOrder?.outputAsset ?? []
            if outputs.count == 1 {
                TokenLogoView(
                    currencySymbol: outputs.first?.currencySymbol,
                    tokenName: outputs.first?.tokenName,
                    isVerified: outputs.first?.isVerified,
                    size: .init(width: 24, height: 24)
                )
            } else if let first = outputs.first, let last = outputs.last {
                ZStack {
                    TokenLogoView(
                        currencySymbol: first.currencySymbol,
                        tokenName: first.tokenName,
                        isVerified: false,
                        forceVerified: true,
                        size: .init(width: 24, height: 24)
                    )
                    .mask {
                        HalfCircleMask(isLeft: true)
                    }
                    TokenLogoView(
                        currencySymbol: last.currencySymbol,
                        tokenName: last.tokenName,
                        isVerified: false,
                        forceVerified: true,
                        size: .init(width: 24, height: 24)
                    )
                    .mask {
                        HalfCircleMask(isLeft: false)
                    }
                }
            }
            Spacer()
            Text(wrapOrder?.orderType.title)
                .font(.labelMediumSecondary)
                .foregroundStyle(.colorBaseTent)
            let image = wrapOrder?.source?.image ?? wrapOrder?.protocolSource?.image
            if let image = image {
                Text("via")
                    .font(.labelMediumSecondary)
                    .foregroundStyle(.colorInteractiveTentPrimarySub)
                ZStack {
                    Image(image)
                        .fixSize(24)
                    if wrapOrder?.source != nil {
                        Image(.icAggrsource)
                            .fixSize(16)
                            .position(x: 2, y: 2)
                    }
                }
                .frame(width: 24, height: 24)
                .padding(.leading, wrapOrder?.source != nil ? 4 : 0)
            }
        }
    }
}

#Preview {
    VStack {
        OrderHistoryView()
            .padding(.horizontal, .xl)
        Spacer()
    }

}
