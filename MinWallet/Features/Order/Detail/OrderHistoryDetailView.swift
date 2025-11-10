import SwiftUI
import FlowStacks


struct OrderHistoryDetailView: View {
    @EnvironmentObject
    private var navigator: FlowNavigator<MainCoordinatorViewModel.Screen>
    @EnvironmentObject
    private var hud: HUDState
    @EnvironmentObject
    private var bannerState: BannerState
    @EnvironmentObject
    private var userInfo: UserInfo
    @EnvironmentObject
    private var appSetting: AppSetting
    @State
    var wrapOrder: WrapOrderHistory = .init()
    @State
    var order: OrderHistory = .init()
    @State
    private var isExchangeRate: Bool = true
    @State
    private var isExchangeLimitRate: Bool = true
    @State
    private var isExchangeStopRate: Bool = true
    @State
    private var showCancelOrder: Bool = false
    @State
    private var showCancelOrderList: Bool = false
    @State
    private var isShowSignContract: Bool = false

    //Cancel
    @State
    var ordersCancel: [OrderHistory] = []
    @State
    private var orderCancelSelected: [String: OrderHistory] = [:]
    @State
    private var orderCancelCanSelect: [String: OrderHistory] = [:]

    ///Show popover
    @State
    private var popoverTarget: UUID?
    @State
    private var idWithProtocolName: [UUID?: String] = [:]
    @Namespace
    private var nsPopover
    @State
    private var workItem: DispatchWorkItem?
    private let uuidAggSource = UUID()

    private var hasOnlyOneOrderCancel: Bool {
        wrapOrder.orders.count == 1 && wrapOrder.orders.first?.status == .created
    }

    var onReloadOrder: (() -> Void)?

    var body: some View {
        VStack(spacing: 0) {
            ZStack {
                ScrollView {
                    VStack(alignment: .leading, spacing: 0) {
                        tokenView
                            .padding(.horizontal, .xl)
                            .padding(.top, .lg)
                        HStack(alignment: .top, spacing: 0) {
                            Text("You paid")
                                .font(.paragraphSmall)
                                .foregroundStyle(.colorInteractiveTentPrimarySub)
                                .padding(.trailing, .xs)
                            Spacer()
                            let inputs = wrapOrder.inputAsset
                            VStack(alignment: .trailing, spacing: 4) {
                                ForEach(inputs, id: \.self) { input in
                                    Text(
                                        input.amount
                                            .formatNumber(
                                                suffix: input.currency,
                                                roundingOffset: input.decimals,
                                                font: .labelSmallSecondary,
                                                fontColor: .colorBaseTent
                                            )
                                    )
                                    .lineLimit(1)
                                    .minimumScaleFactor(0.1)
                                }
                            }
                            if wrapOrder.percent > 0 {
                                Text(" · \(wrapOrder.percent.formatSNumber(maximumFractionDigits: 2))%")
                                    .font(.labelSmallSecondary)
                                    .foregroundStyle(.colorInteractiveToneHighlight)
                                    .lineLimit(1)
                                    .minimumScaleFactor(0.1)
                            }
                        }
                        .frame(minHeight: 36)
                        .padding(.horizontal, .xl)
                        HStack(alignment: .top) {
                            Text("You receive")
                                .font(.paragraphSmall)
                                .foregroundStyle(.colorInteractiveTentPrimarySub)
                            Spacer()
                            if wrapOrder.orders.allSatisfy({ $0.status != .batched }) {
                                Text("--")
                                    .font(.labelSmallSecondary)
                                    .foregroundStyle(.colorBaseTent)
                                    .lineLimit(1)
                                    .minimumScaleFactor(0.1)
                            } else {
                                let outputs = wrapOrder.outputAsset.filter({ $0.amount > 0 })
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
                                        }
                                    }
                                }
                            }
                        }
                        .frame(minHeight: 36)
                        .padding(.horizontal, .xl)
                        HStack {
                            Text("Status")
                                .font(.paragraphSmall)
                                .foregroundStyle(.colorInteractiveTentPrimarySub)
                            Spacer()
                            HStack(spacing: 4) {
                                Circle().frame(width: 4, height: 4)
                                    .foregroundStyle(wrapOrder.status.foregroundCircleColor)
                                Text(wrapOrder.status.title)
                                    .font(.paragraphXMediumSmall)
                                    .foregroundStyle(wrapOrder.status.foregroundColor)
                            }
                            .padding(.horizontal, .lg)
                            .padding(.vertical, .xs)
                            .background(
                                RoundedRectangle(cornerRadius: BorderRadius.full).fill(wrapOrder.status.backgroundColor)
                            )
                            .frame(height: 20)
                            .lineLimit(1)
                        }
                        .frame(height: 40)
                        .padding(.horizontal, .xl)
                        Color.colorBorderPrimarySub.frame(height: 1)
                            .padding(.xl)
                        if wrapOrder.orders.first?.aggregatorSource != nil || wrapOrder.orders.count > 1 {
                            ordersStateInfo
                                .padding(.top, .md)
                                .padding(.bottom, 16 + 8)
                        }
                        inputInfoView.padding(.horizontal, .xl)
                        executeInfoView.padding(.horizontal, .xl)
                        if order.status != .created {
                            outputInfoView.padding(.horizontal, .xl)
                        }
                    }
                }
                customPopover
            }
            .containerShape(.rect)
            .onTapGesture {
                popoverTarget = nil
            }

            if wrapOrder.status == .created {
                Spacer()
                HStack(spacing: .xl) {
                    CustomButton(title: "Cancel", variant: .secondary) {
                        if hasOnlyOneOrderCancel {
                            $showCancelOrder.showSheet()
                        } else {
                            $showCancelOrderList.showSheet()
                        }
                    }
                    .frame(height: 56)
                }
                .padding(EdgeInsets(top: 24, leading: .xl, bottom: .xl, trailing: .xl))
            }
        }
        .modifier(
            BaseContentView(
                screenTitle: " ",
                actionLeft: {
                    navigator.pop()
                })
        )
        .presentSheet(isPresented: $showCancelOrder) {
            OrderHistoryConfirmCancelView {
                Task {
                    do {
                        switch appSetting.authenticationType {
                        case .biometric:
                            try await BiometricAuthentication.authenticateUser()
                            authenticationSuccess()
                        case .password:
                            $isShowSignContract.showSheet()
                        }
                    } catch {
                        bannerState.showBannerError(error)
                    }
                }
            }
        }
        .presentSheet(
            isPresented: $showCancelOrderList,
            onDimiss: {
                orderCancelSelected = [:]
                orderCancelCanSelect = [:]
            },
            content: {
                OrderHistoryCancelView(
                    orders: $ordersCancel,
                    orderSelected: $orderCancelSelected,
                    orderCanSelect: $orderCancelCanSelect,
                    onCancelOrder: {
                        $showCancelOrder.showSheet()
                    })
            }
        )
        .presentSheet(isPresented: $isShowSignContract) {
            SignContractView(
                onSignSuccess: {
                    authenticationSuccess()
                }
            )
        }
    }

    private var tokenView: some View {
        HStack(spacing: .xs) {
            let inputs = wrapOrder.inputAsset
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
            let outputs = wrapOrder.outputAsset
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
            Text(wrapOrder.orderType.title)
                .font(.labelMediumSecondary)
                .foregroundStyle(.colorBaseTent)
            let sourceImage = wrapOrder.source?.image ?? wrapOrder.protocolSource?.image
            let sourceName = wrapOrder.source?.name ?? wrapOrder.protocolSource?.name.toString()
            if let sourceImage = sourceImage, let sourceName = sourceName {
                Text("via")
                    .font(.labelMediumSecondary)
                    .foregroundStyle(.colorInteractiveTentPrimarySub)
                ZStack {
                    Image(sourceImage)
                        .fixSize(24)
                    if wrapOrder.source != nil {
                        Image(.icAggrsource)
                            .fixSize(16)
                            .position(x: 2, y: 2)
                    }
                }
                .frame(width: 24, height: 24)
                .padding(.leading, wrapOrder.source != nil ? 4 : 0)
                .contentShape(.rect)
                .onTapGesture { showPopover(target: uuidAggSource, protocolName: sourceName) }
                .matchedGeometryEffect(id: uuidAggSource, in: nsPopover, anchor: .bottom)
            }
        }
        .frame(height: 40)
    }

    private var inputInfoView: some View {
        HStack(alignment: .timelineAlignment, spacing: .xl) {
            VStack(spacing: 0) {
                Image(.icInputInfo)
                    .resizable()
                    .frame(width: 36, height: 36)
                    .alignmentGuide(
                        .timelineAlignment,
                        computeValue: { dimension in
                            dimension[VerticalAlignment.center]
                        })
                Color.colorBorderPrimaryDefault.frame(width: 1)
            }
            VStack(alignment: .leading, spacing: 0) {
                Text("Input information")
                    .font(.labelSmallSecondary)
                    .foregroundStyle(.colorBaseTent)
                    .alignmentGuide(
                        .timelineAlignment,
                        computeValue: { dimension in
                            dimension[VerticalAlignment.center]
                        })
                HStack(alignment: .top) {
                    Text("You paid")
                        .font(.paragraphSmall)
                        .foregroundStyle(.colorInteractiveTentPrimarySub)
                    Spacer()
                    let inputs = order.inputAsset
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
                        }
                    }
                }
                .padding(.vertical, .md)
                .padding(.top, .md)
                HStack {
                    Text("Refundable deposit")
                        .font(.paragraphSmall)
                        .foregroundStyle(.colorInteractiveTentPrimarySub)
                    Spacer()
                    Text((order.depositAda.toExact(decimal: 6).formatSNumber(maximumFractionDigits: 15)) + " " + Currency.ada.prefix)
                        .font(.labelSmallSecondary)
                        .foregroundStyle(.colorBaseTent)
                }
                .padding(.vertical, .md)
                HStack {
                    Text("Estimated execution fee")
                        .font(.paragraphSmall)
                        .foregroundStyle(.colorInteractiveTentPrimarySub)
                    Spacer()
                    Text(((order.batcherFee) / 1_000_000).formatSNumber(maximumFractionDigits: 15) + " " + Currency.ada.prefix)
                        .font(.labelSmallSecondary)
                        .foregroundStyle(.colorBaseTent)
                }
                .padding(.vertical, .md)
                HStack(spacing: 4) {
                    Text("Created at")
                        .font(.paragraphSmall)
                        .foregroundStyle(.colorInteractiveTentPrimarySub)
                    Spacer()
                    Text(order.createdAt?.formattedDateGMT)
                        .underline()
                        .baselineOffset(4)
                        .font(.labelSmallSecondary)
                        .foregroundStyle(.colorBaseTent)
                        .multilineTextAlignment(.trailing)
                        .onTapGesture {
                            order.createdTxId.viewTransaction()
                        }
                    Image(.icArrowUp)
                        .fixSize(.xl)
                        .onTapGesture {
                            order.createdTxId.viewTransaction()
                        }
                }
                .padding(.top, .md)
                .padding(.bottom, .xl)
            }
        }
    }

    private var executeInfoView: some View {
        HStack(alignment: .timelineAlignment, spacing: .xl) {
            VStack(spacing: 0) {
                Image(.icExecuteInfo)
                    .resizable()
                    .frame(width: 36, height: 36)
                    .alignmentGuide(
                        .timelineAlignment,
                        computeValue: { dimension in
                            dimension[VerticalAlignment.center]
                        })
                if order.status != .created {
                    Color.colorBorderPrimaryDefault.frame(width: 1)
                }
            }
            VStack(alignment: .leading, spacing: 0) {
                Text("Execution information")
                    .font(.labelSmallSecondary)
                    .foregroundStyle(.colorBaseTent)
                    .alignmentGuide(
                        .timelineAlignment,
                        computeValue: { dimension in
                            dimension[VerticalAlignment.center]
                        }
                    )
                    .padding(.bottom, .md)
                if order.detail.orderType == .oco {
                    HStack(spacing: 4) {
                        Text("Stop amount")
                            .font(.paragraphSmall)
                            .foregroundStyle(.colorInteractiveTentPrimarySub)
                        Spacer()
                        Text(
                            order.detail.stopAmount
                                .toExact(decimal: order.output?.decimals)
                                .formatNumber(
                                    suffix: order.output?.currency ?? "",
                                    roundingOffset: order.output?.decimals,
                                    font: .labelSmallSecondary,
                                    fontColor: .colorBaseTent
                                )
                        )
                        .lineLimit(1)
                    }
                    .padding(.vertical, .md)
                    if let input = order.input, let output = order.output, order.detail.stopAmount > 0 {
                        HStack(spacing: 4) {
                            Text("Stop price")
                                .font(.paragraphSmall)
                                .foregroundStyle(.colorInteractiveTentPrimarySub)
                            Spacer()
                            let rate = pow(
                                order.detail.stopAmount.toExact(decimal: output.decimals) / (input.amount == 0 ? 1 : input.amount),
                                isExchangeStopRate ? 1 : -1
                            )
                            Text("1 \(isExchangeStopRate ? input.asset.adaName : output.asset.adaName) = ")
                                .font(.labelSmallSecondary)
                                .foregroundColor(.colorBaseTent) + Text(rate.formatNumber(font: .labelSmallSecondary, fontColor: .colorBaseTent)) + Text(" \(!isExchangeStopRate ? input.asset.adaName : output.asset.adaName)").font(.labelSmallSecondary).foregroundColor(.colorBaseTent)
                            Image(.icExecutePrice)
                                .fixSize(.xl)
                        }
                        .padding(.vertical, .md)
                        .contentShape(.rect)
                        .onTapGesture {
                            isExchangeStopRate.toggle()
                        }
                    }
                    HStack(alignment: .top) {
                        Text("Limit amount")
                            .font(.paragraphSmall)
                            .foregroundStyle(.colorInteractiveTentPrimarySub)
                        Spacer()
                        Text(
                            order.detail.limitAmount
                                .toExact(decimal: order.output?.decimals)
                                .formatNumber(
                                    suffix: order.output?.currency ?? "",
                                    roundingOffset: order.output?.decimals,
                                    font: .labelSmallSecondary,
                                    fontColor: .colorBaseTent
                                )
                        )
                        .lineLimit(1)
                    }
                    .padding(.vertical, .md)
                    if let input = order.input, let output = order.output, order.detail.limitAmount > 0 {
                        HStack(spacing: 4) {
                            Text("Limit price")
                                .font(.paragraphSmall)
                                .foregroundStyle(.colorInteractiveTentPrimarySub)
                            Spacer()
                            let rate = pow(
                                order.detail.limitAmount.toExact(decimal: output.decimals) / (input.amount == 0 ? 1 : input.amount),
                                isExchangeLimitRate ? 1 : -1
                            )
                            Text("1 \(isExchangeLimitRate ? input.asset.adaName : output.asset.adaName) = ")
                                .font(.labelSmallSecondary)
                                .foregroundColor(.colorBaseTent) + Text(rate.formatNumber(font: .labelSmallSecondary, fontColor: .colorBaseTent)) + Text(" \(!isExchangeLimitRate ? input.asset.adaName : output.asset.adaName)").font(.labelSmallSecondary).foregroundColor(.colorBaseTent)
                            Image(.icExecutePrice)
                                .fixSize(.xl)
                        }
                        .padding(.vertical, .md)
                        .contentShape(.rect)
                        .onTapGesture {
                            isExchangeLimitRate.toggle()
                        }
                    }
                } else if order.detail.orderType == .stopLoss {
                    HStack(spacing: 4) {
                        Text("Stop amount")
                            .font(.paragraphSmall)
                            .foregroundStyle(.colorInteractiveTentPrimarySub)
                        Spacer()
                        Text(
                            order.detail.minimumAmount
                                .toExact(decimal: order.output?.decimals)
                                .formatNumber(
                                    suffix: order.output?.currency ?? "",
                                    roundingOffset: order.output?.decimals,
                                    font: .labelSmallSecondary,
                                    fontColor: .colorBaseTent
                                )
                        )
                        .lineLimit(1)
                    }
                    .padding(.vertical, .md)
                    if let input = order.input, let output = order.output, order.detail.minimumAmount > 0 {
                        HStack(spacing: 4) {
                            Text("Stop price")
                                .font(.paragraphSmall)
                                .foregroundStyle(.colorInteractiveTentPrimarySub)
                            Spacer()
                            let rate = pow(
                                order.detail.minimumAmount.toExact(decimal: output.decimals) / (input.amount == 0 ? 1 : input.amount),
                                isExchangeStopRate ? 1 : -1
                            )
                            Text("1 \(isExchangeStopRate ? input.asset.adaName : output.asset.adaName) = ")
                                .font(.labelSmallSecondary)
                                .foregroundColor(.colorBaseTent) + Text(rate.formatNumber(font: .labelSmallSecondary, fontColor: .colorBaseTent)) + Text(" \(!isExchangeStopRate ? input.asset.adaName : output.asset.adaName)").font(.labelSmallSecondary).foregroundColor(.colorBaseTent)
                            Image(.icExecutePrice)
                                .fixSize(.xl)
                        }
                        .padding(.vertical, .md)
                        .contentShape(.rect)
                        .onTapGesture {
                            isExchangeStopRate.toggle()
                        }
                    }
                } else if order.detail.orderType == .partialSwap {
                    if order.detail.limitAmount > 0 {
                        HStack(alignment: .top) {
                            Text("Limit amount")
                                .font(.paragraphSmall)
                                .foregroundStyle(.colorInteractiveTentPrimarySub)
                            Spacer()
                            Text(
                                order.detail.limitAmount
                                    .toExact(decimal: order.output?.decimals)
                                    .formatNumber(
                                        suffix: order.output?.currency ?? "",
                                        roundingOffset: order.output?.decimals,
                                        font: .labelSmallSecondary,
                                        fontColor: .colorBaseTent
                                    )
                            )
                            .lineLimit(1)
                        }
                        .padding(.vertical, .md)
                    }
                    if order.detail.maxSwapTime > 0 {
                        HStack(alignment: .top) {
                            Text("Max swap times")
                                .font(.paragraphSmall)
                                .foregroundStyle(.colorInteractiveTentPrimarySub)
                            Spacer()
                            Text(Double(order.detail.maxSwapTime).formatNumber(font: .labelSmallSecondary, fontColor: .colorBaseTent))
                                .lineLimit(1)
                        }
                        .padding(.vertical, .md)
                    }
                    if order.detail.minSwapAmount > 0 {
                        HStack(alignment: .top) {
                            Text("Minimum swap amount")
                                .font(.paragraphSmall)
                                .foregroundStyle(.colorInteractiveTentPrimarySub)
                            Spacer()
                            Text(order.detail.minSwapAmount.toExact(decimal: order.input?.decimals).formatNumber(suffix: order.input?.currency ?? "", font: .labelSmallSecondary, fontColor: .colorBaseTent))
                                .lineLimit(1)
                        }
                        .padding(.vertical, .md)
                    }
                } else {
                    if order.detail.orderType == .zapIn || order.detail.orderType == .zapOut {
                        HStack(alignment: .top) {
                            Text("Swap amount")
                                .font(.paragraphSmall)
                                .foregroundStyle(.colorInteractiveTentPrimarySub)
                            Spacer()
                            Text(
                                order.detail.swapAmount
                                    .toExact(decimal: order.detail.orderType == .zapIn ? order.input?.decimals : order.output?.decimals)
                                    .formatNumber(
                                        suffix: order.detail.orderType == .zapIn ? (order.input?.currency ?? "") : (order.output?.currency ?? ""),
                                        font: .labelSmallSecondary,
                                        fontColor: .colorBaseTent
                                    )
                            )
                            .lineLimit(1)
                        }
                        .padding(.vertical, .md)
                    }

                    if order.detail.orderType == .limit, let input = order.input, let output = order.output, order.detail.minimumAmount > 0 {
                        HStack(spacing: 4) {
                            Text("Limit price")
                                .font(.paragraphSmall)
                                .foregroundStyle(.colorInteractiveTentPrimarySub)
                            Spacer()
                            let rate = pow(
                                order.detail.minimumAmount.toExact(decimal: output.decimals) / (input.amount == 0 ? 1 : input.amount),
                                isExchangeLimitRate ? 1 : -1
                            )
                            Text("1 \(isExchangeLimitRate ? input.asset.adaName : output.asset.adaName) = ")
                                .font(.labelSmallSecondary)
                                .foregroundColor(.colorBaseTent) + Text(rate.formatNumber(font: .labelSmallSecondary, fontColor: .colorBaseTent)) + Text(" \(!isExchangeLimitRate ? input.asset.adaName : output.asset.adaName)").font(.labelSmallSecondary).foregroundColor(.colorBaseTent)
                            Image(.icExecutePrice)
                                .fixSize(.xl)
                        }
                        .padding(.vertical, .md)
                        .contentShape(.rect)
                        .onTapGesture {
                            isExchangeLimitRate.toggle()
                        }
                    }
                    HStack(alignment: .top) {
                        Text(
                            order.detail.orderType == .limit || order.detail.orderType == .oco || order.detail.orderType == .stopLoss ? "Limit amount" : "Minimum receive"
                        )
                        .font(.paragraphSmall)
                        .foregroundStyle(.colorInteractiveTentPrimarySub)
                        Spacer()
                        let outputs = order.outputAsset
                        VStack(alignment: .trailing, spacing: 4) {
                            ForEach(outputs, id: \.self) { output in
                                Text(output.minimumAmount.formatNumber(suffix: output.currency, font: .labelSmallSecondary, fontColor: .colorBaseTent))
                                    .lineLimit(1)
                            }
                        }
                    }
                    .padding(.vertical, .md)
                }
                if let tradingFeeAsset = order.tradingFeeAsset, !tradingFeeAsset.amount.isZero {
                    HStack(alignment: .top) {
                        Text("Trading fee")
                            .font(.paragraphSmall)
                            .foregroundStyle(.colorInteractiveTentPrimarySub)
                        Spacer()
                        VStack(alignment: .trailing, spacing: 4) {
                            Text(tradingFeeAsset.amount.formatNumber(suffix: tradingFeeAsset.currency, font: .labelSmallSecondary, fontColor: .colorBaseTent))
                                .lineLimit(1)
                        }
                    }
                    .padding(.vertical, .md)
                }
                if order.status == .batched {
                    HStack {
                        Text("Executed fee")
                            .font(.paragraphSmall)
                            .foregroundStyle(.colorInteractiveTentPrimarySub)
                        Spacer()
                        Text(((order.batcherFee) / 1_000_000).formatSNumber(maximumFractionDigits: 15) + " " + Currency.ada.prefix)
                            .font(.labelSmallSecondary)
                            .foregroundStyle(.colorBaseTent)
                    }
                    .padding(.vertical, .md)
                }
                if order.isShowRouter, !order.routing.isEmpty {
                    HStack(spacing: 4) {
                        Text("Route")
                            .font(.paragraphSmall)
                            .foregroundStyle(.colorInteractiveTentPrimarySub)
                        Spacer()
                        Text(order.routing)
                            .font(.labelSmallSecondary)
                            .foregroundStyle(.colorBaseTent)
                    }
                    .padding(.top, .md)
                }
                if let expiredAt = order.detail.expireAt, !expiredAt.isEmpty, order.status == .created {
                    HStack(spacing: 4) {
                        Text("Expires at")
                            .font(.paragraphSmall)
                            .foregroundStyle(.colorInteractiveTentPrimarySub)
                        Spacer()
                        Text(expiredAt.formattedDateGMT)
                            .underline()
                            .baselineOffset(4)
                            .font(.labelSmallSecondary)
                            .foregroundStyle(.colorBaseTent)
                            .onTapGesture {
                                order.createdTxId.viewTransaction()
                            }
                        Image(.icArrowUp)
                            .fixSize(.xl)
                            .onTapGesture {
                                order.createdTxId.viewTransaction()
                            }
                    }
                    .padding(.top, .md)
                }
            }
            .padding(.bottom, .xl)
        }
    }

    private var outputInfoView: some View {
        HStack(alignment: .timelineAlignment, spacing: .xl) {
            VStack(spacing: 0) {
                Image(.icOutputInfo)
                    .resizable()
                    .frame(width: 36, height: 36)
                    .alignmentGuide(
                        .timelineAlignment,
                        computeValue: { dimension in
                            dimension[VerticalAlignment.center]
                        })
            }
            VStack(alignment: .leading, spacing: 0) {
                Text("Output information")
                    .font(.labelSmallSecondary)
                    .foregroundStyle(.colorBaseTent)
                    .alignmentGuide(
                        .timelineAlignment,
                        computeValue: { dimension in
                            dimension[VerticalAlignment.center]
                        }
                    )
                    .padding(.bottom, .md)
                if order.status == .batched {
                    HStack(alignment: .top) {
                        Text("You receive")
                            .font(.paragraphSmall)
                            .foregroundStyle(.colorInteractiveTentPrimarySub)
                        Spacer()
                        let outputs = order.outputAsset
                        VStack(alignment: .trailing, spacing: 4) {
                            ForEach(outputs, id: \.self) { output in
                                Text(
                                    output.amount
                                        .formatNumber(
                                            suffix: output.currency,
                                            roundingOffset: output.decimals,
                                            font: .labelSmallSecondary,
                                            fontColor: .colorBaseSuccess
                                        )
                                )
                                .lineLimit(1)
                            }
                        }
                    }
                    .padding(.vertical, .md)
                    if order.isShowExecutedPrice, let input = order.input, let output = order.output {
                        HStack(spacing: 4) {
                            Text("Executed price")
                                .font(.paragraphSmall)
                                .foregroundStyle(.colorInteractiveTentPrimarySub)
                            Spacer()
                            let rate = pow(output.amount / (input.amount == 0 ? 1 : input.amount), isExchangeRate ? 1 : -1)
                            Text("1 \(isExchangeRate ? input.asset.adaName : output.asset.adaName) = ")
                                .font(.labelSmallSecondary)
                                .foregroundColor(.colorBaseTent) + Text(rate.formatNumber(font: .labelSmallSecondary, fontColor: .colorBaseTent)) + Text(" \(!isExchangeRate ? input.asset.adaName : output.asset.adaName)").font(.labelSmallSecondary).foregroundColor(.colorBaseTent)
                            Image(.icExecutePrice)
                                .fixSize(.xl)
                        }
                        .padding(.vertical, .md)
                        .contentShape(.rect)
                        .onTapGesture {
                            isExchangeRate.toggle()
                        }
                    }
                    if let changeAmount = order.changeAmountAsset {
                        HStack(alignment: .top) {
                            Text("Change amount")
                                .font(.paragraphSmall)
                                .foregroundStyle(.colorInteractiveTentPrimarySub)
                            Spacer()
                            VStack(alignment: .trailing, spacing: 4) {
                                Text(changeAmount.amount.formatNumber(suffix: changeAmount.currency, font: .labelSmallSecondary, fontColor: .colorBaseTent))
                                    .lineLimit(1)
                            }
                        }
                        .padding(.vertical, .md)
                    }
                    HStack {
                        Text("Refundable deposit")
                            .font(.paragraphSmall)
                            .foregroundStyle(.colorInteractiveTentPrimarySub)
                        Spacer()
                        Text(((order.depositAda) / 1_000_000).formatSNumber(maximumFractionDigits: 15) + " " + Currency.ada.prefix)
                            .font(.labelSmallSecondary)
                            .foregroundStyle(.colorBaseTent)
                    }
                    .padding(.vertical, .md)
                }
                HStack(spacing: 4) {
                    Text(order.status == .batched ? "Batched at" : "Cancelled at")
                        .font(.paragraphSmall)
                        .foregroundStyle(.colorInteractiveTentPrimarySub)
                    Spacer()
                    Text(order.updatedAt?.formattedDateGMT)
                        .underline()
                        .baselineOffset(4)
                        .font(.labelSmallSecondary)
                        .foregroundStyle(.colorBaseTent)
                        .multilineTextAlignment(.trailing)
                        .onTapGesture {
                            order.updatedTxId?.viewTransaction()
                        }
                    Image(.icArrowUp)
                        .fixSize(.xl)
                        .onTapGesture {
                            order.updatedTxId?.viewTransaction()
                        }
                }
                .padding(.top, .md)
                let fillHistories = order.detail.fillHistory
                if !fillHistories.isEmpty && order.status == .batched {
                    Color.colorBorderPrimarySub.frame(height: 1)
                        .padding(.vertical, .xl)
                    HStack(spacing: 4) {
                        Text(fillHistories.count == 1 ? "Fill History" : "Fill Histories")
                            .font(.paragraphSmall)
                            .foregroundStyle(.colorInteractiveTentPrimarySub)
                        Spacer()
                    }
                    .padding(.bottom, .md)
                    ForEach(fillHistories, id: \.self) { history in
                        HStack(spacing: 4) {
                            Text(history.input.amount.formatNumber(suffix: history.input.currency, roundingOffset: history.input.decimals, font: .labelSmallSecondary, fontColor: .colorBaseTent))
                            Image(.icBack)
                                .fixSize(.xl)
                                .rotationEffect(.degrees(180))
                            Text(history.output.amount.formatNumber(suffix: history.output.currency, roundingOffset: history.output.decimals, font: .labelSmallSecondary, fontColor: .colorBaseTent))
                            Text("\(abs(history.percent).formatSNumber(maximumFractionDigits: 2))%")
                                .font(.paragraphSmall)
                                .foregroundStyle(.colorInteractiveToneHighlight)
                                .layoutPriority(9)
                            Spacer(minLength: 0)
                            Image(.icArrowUp)
                                .fixSize(.xl)
                                .onTapGesture {
                                    history.batchedTxId.viewTransaction()
                                }
                        }
                        .frame(height: 36)
                    }
                }
            }
        }
    }

    private func cancelOrder() async throws -> String? {
        var orders: [OrderHistory] = hasOnlyOneOrderCancel ? wrapOrder.orders : orderCancelSelected.map({ _, value in value })
        let jsonData = try await OrderAPIRouter.cancelOrder(address: userInfo.minWallet?.address ?? "", orders: orders).async_request()
        try APIRouterCommon.parseDefaultErrorMessage(jsonData)

        guard let tx = jsonData["cbor"].string, !tx.isEmpty else { throw AppGeneralError.localErrorLocalized(message: "Transaction not found") }
        let finalID = try await TokenManager.finalizeAndSubmitV2(txRaw: tx)

        orders = await OrderHistoryViewModel.getOrders(orders: orders)
        let wrapOrders = wrapOrder.orders.map({ history in
            orders.first { $0.id == history.id } ?? history
        })

        self.wrapOrder = .init(orders: wrapOrders, key: self.wrapOrder.id)
        self.order = orders.first(where: { $0.id == self.order.id }) ?? self.order

        return finalID
    }

    private func authenticationSuccess() {
        Task {
            do {
                hud.showLoading(true)
                let finalID = try await cancelOrder()
                onReloadOrder?()
                hud.showLoading(false)
                bannerState.infoContent = {
                    bannerState.infoContentDefault(onViewTransaction: {
                        finalID?.viewTransaction()
                    })
                }
                bannerState.showBanner(isShow: true)
            } catch {
                hud.showLoading(false)
                bannerState.showBannerError(error.localizedDescription)
            }
        }
    }

    @ViewBuilder
    private var ordersStateInfo: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Total: \(wrapOrder.orders.count) TXs")
                .font(.paragraphXMediumSmall)
                .foregroundStyle(.colorBaseTent)
                .padding(.horizontal, .lg)
                .padding(.vertical, .xs)
                .background(
                    RoundedRectangle(cornerRadius: BorderRadius.full).fill(.colorSurfacePrimaryDefault)
                )
                .frame(height: 24)
                .padding(.horizontal, .xl)
            ScrollView(.horizontal) {
                HStack(spacing: 0) {
                    ForEach(Array(wrapOrder.orders.enumerated()), id: \.offset) { index, order in
                        let isSelected: Binding<Bool> = .constant(self.order.id == order.id)
                        OrderHistoryItemStatusView(
                            number: index + 1,
                            isShowStatus: true,
                            isShowSelected: false,
                            isSelected: isSelected,
                            isCanSelect: .constant(true),
                            order: order
                        )
                        .padding(.leading, .xl)
                        .padding(.bottom, 2)
                        .frame(minWidth: (UIScreen.current?.bounds.width ?? 375) * 0.7)
                        .contentShape(.rect)
                        .onTapGesture {
                            self.order = order
                        }
                    }
                }
            }
            .scrollIndicators(.hidden)
        }
    }
}


fileprivate extension VerticalAlignment {
    struct TimelineAlignment: AlignmentID {
        static func defaultValue(in context: ViewDimensions) -> CGFloat {
            context[.top]
        }
    }

    static let timelineAlignment = VerticalAlignment(TimelineAlignment.self)
}

extension OrderHistoryDetailView {
    @ViewBuilder
    private var customPopover: some View {
        if let popoverTarget {
            Text("Via \(idWithProtocolName[popoverTarget] ?? "")")
                .font(.paragraphXSmall)
                .foregroundStyle(.colorTextTooltip)
                .padding(.vertical, .md)
                .padding(.horizontal, 14)
                .background(
                    RoundedRectangle(cornerRadius: .md)
                        .fill(Color(.colorBackgroundTooltip))
                )
                .foregroundColor(.colorBackgroundTooltip)
                .offset(y: 10)
                .matchedGeometryEffect(
                    id: popoverTarget,
                    in: nsPopover,
                    properties: .position,
                    anchor: .trailing,
                    isSource: false
                )
                .transition(.opacity.combined(with: .scale))
                .zIndex(1)
        }
    }

    private func showPopover(target: UUID, protocolName: String) {
        workItem?.cancel()
        workItem = DispatchWorkItem(block: {
            self.popoverTarget = nil
        })

        if popoverTarget != nil {
            popoverTarget = nil
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.01) {
                popoverTarget = target
            }
        } else {
            popoverTarget = target
        }
        idWithProtocolName[target] = protocolName
        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(2), execute: workItem!)
    }
}
#Preview {
    OrderHistoryDetailView()
}
