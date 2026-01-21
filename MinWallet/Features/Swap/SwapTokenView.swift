import SwiftUI
import FlowStacks
import SkeletonUI


struct SwapTokenView: View {
    enum FocusedField: Hashable {
        case pay
        case receive
    }
    
    @EnvironmentObject
    private var navigator: FlowNavigator<MainCoordinatorViewModel.Screen>
    @EnvironmentObject
    private var appSetting: AppSetting
    @EnvironmentObject
    private var hudState: HUDState
    @EnvironmentObject
    private var bannerState: BannerState
    @StateObject
    private var viewModel: SwapTokenViewModel
    @FocusState
    private var focusedField: FocusedField?
    @State
    private var isShowSignContract: Bool = false
    @State
    private var isShowToolTip: Bool = false
    @State
    private var isShowDescView: Bool = false
    @State
    private var content: LocalizedStringKey = ""
    @State
    private var title: LocalizedStringKey = ""
    
    @State
    private var swapSettingCached: SwapTokenSetting = .init()
    @State
    private var excludedPoolsCached: [String: AggregatorSource] = [:]
    
    init(viewModel: SwapTokenViewModel) {
        viewModel.swapSetting.excludedPools = [.MuesliSwap]
        self._excludedPoolsCached = .init(wrappedValue: [AggregatorSource.MuesliSwap.rawId: .MuesliSwap])
        self._swapSettingCached = .init(wrappedValue: viewModel.swapSetting)
        _viewModel = .init(wrappedValue: viewModel)
    }
    
    var body: some View {
        VStack(spacing: 0) {
            ScrollView {
                VStack(spacing: 0) {
                    contentView
                        .onChange(of: focusedField) { focusedField in
                            guard let focusedField = focusedField else { return }
                            viewModel.isSwapExactIn = focusedField == .pay
                        }
                }
            }
            Spacer()
            bottomView
            let combinedBinding = Binding<Bool>(
                get: { viewModel.enableSwap },
                set: { _ in }
            )
            let swapTitle: LocalizedStringKey = viewModel.errorInfo?.content ?? "Swap"
            CustomButton(title: swapTitle, isEnable: combinedBinding) {
                processingSwapToken()
            }
            .frame(height: 56)
            .padding(.horizontal, .xl)
            .padding(.top, .xl)
        }
        .toolbar {
            ToolbarItemGroup(placement: .keyboard) {
                Spacer()
                
                Button("Done") {
                    hideKeyboard()
                }
                .foregroundStyle(.colorLabelToolbarDone)
            }
        }
        .modifier(
            BaseContentView(
                screenTitle: "Swap aggregator",
                iconRight: .icSwapTokenSetting,
                alignmentTitle: .leading,
                actionLeft: {
                    navigator.pop()
                },
                actionRight: {
                    hideKeyboard()
                    $viewModel.isShowSwapSetting.showSheet()
                })
        )
        .modifier(DismissingKeyboard())
        .presentSheet(isPresented: $viewModel.isShowInfo) {
            SwapTokenInfoView(
                viewModel: viewModel,
                onShowToolTip: { (title, content) in
                    self.content = content
                    self.title = title
                    $isShowToolTip.showSheet()
                },
                onSwap: {
                    processingSwapToken()
                }
            )
        }
        .presentSheet(isPresented: $viewModel.isShowRouting) {
            SwapTokenRoutingView()
                .environmentObject(viewModel)
        }
        .presentSheet(
            isPresented: $viewModel.isShowSelectToken,
            onDimiss: {
                viewModel.action.send(.hiddenSelectToken)
            },
            content: {
                SelectTokenView(
                    viewModel: viewModel.selectTokenVM,
                    onSelectToken: { tokens, _ in
                        viewModel.action.send(.selectToken(token: tokens.first))
                    }
                )
                .frame(height: (UIScreen.current?.bounds.height ?? 0) * 0.83)
                .presentSheetModifier()
            }
        )
        .presentSheet(
            isPresented: $viewModel.isShowSwapSetting,
            onDimiss: {
                swapSettingCached = viewModel.swapSetting
            },
            content: {
                SwapTokenSettingView(
                    onShowToolTip: { title, content in
                        self.content = content
                        self.title = title
                        $isShowToolTip.showSheet()
                    },
                    showCustomizedRoute: $viewModel.isShowCustomizedRoute,
                    swapTokenSetting: $swapSettingCached,
                    onSave: {
                        viewModel.swapSetting = swapSettingCached
                        viewModel.action.send(.getTradingInfo)
                    }
                )
            }
        )
        .ignoresSafeArea(.keyboard)
        .presentSheet(isPresented: $isShowSignContract) {
            SignContractView(
                onSignSuccess: {
                    swapTokenSuccess()
                }
            )
        }
        .presentSheet(isPresented: $isShowToolTip) {
            TokenDetailToolTipView(title: $title, content: $content)
                .background(content: {
                    RoundedCorners(lineWidth: 0, tl: 24, tr: 24, bl: 0, br: 0)
                        .fill(.colorBaseBackground)
                        .ignoresSafeArea()
                })
                .ignoresSafeArea()
        }
        .presentSheet(isPresented: $isShowDescView) {
            SwapTokenDescriptionView(onDismiss: {
                isShowDescView = false
            })
            .background(content: {
                RoundedCorners(lineWidth: 0, tl: 24, tr: 24, bl: 0, br: 0)
                    .fill(.colorBaseBackground)
                    .ignoresSafeArea()
            })
            .ignoresSafeArea()
        }
        .presentSheet(
            isPresented: $viewModel.isShowCustomizedRoute,
            onDimiss: {
                excludedPoolsCached = swapSettingCached.excludedPools.reduce([:]) { result, source in
                    result.appending([source.rawId: source])
                }
            },
            content: {
                SwapTokenCustomizedRouteView(
                    excludedSource: $excludedPoolsCached,
                    onSave: {
                        self.swapSettingCached.excludedPools = Array(excludedPoolsCached.values)
                    })
            }
        )
        .onAppear { [weak viewModel] in
            viewModel?.bannerState = bannerState
            viewModel?.subscribeCombine()
        }
        .onDisappear { [weak viewModel] in
            viewModel?.unsubscribeCombine()
        }
    }
    
    @ViewBuilder
    private var contentView: some View {
        tokenPayView
        Image(.icSwap)
            .resizable().frame(width: 36, height: 36)
            .padding(.top, -16)
            .padding(.bottom, -16)
            .zIndex(999)
            .containerShape(.rect)
            .onTapGesture {
                hideKeyboard()
                viewModel.action.send(.swapToken)
            }
        tokenReceiveView
        routingView
        descriptionView
        warningView
    }
    
    @ViewBuilder
    private var tokenPayView: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack(alignment: .lastTextBaseline, spacing: 6) {
                Text("You pay")
                    .font(.paragraphSmall)
                    .foregroundStyle(.colorInteractiveTentPrimarySub)
                Spacer()
                Text("Half")
                    .font(.paragraphXMediumSmall)
                    .foregroundStyle(.colorInteractiveToneHighlight)
                    .onTapGesture {
                        viewModel.action.send(.setHalfAmount)
                    }
                Text("Max")
                    .font(.paragraphXMediumSmall)
                    .foregroundStyle(.colorInteractiveToneHighlight)
                    .onTapGesture {
                        viewModel.action.send(.setMaxAmount)
                    }
            }
            HStack(alignment: .center, spacing: 6) {
                if !viewModel.isSwapExactIn && viewModel.isGettingTradeInfo {
                    HStack(spacing: 0) {
                        Text("")
                    }
                    .skeleton(with: true)
                    .frame(width: 124, height: 32)
                } else {
                    let minValueBinding = Binding<Double>(
                        get: { pow(10, Double(viewModel.tokenPay.token.decimals) * -1) },
                        set: { _ in }
                    )
                    AmountTextField(
                        value: $viewModel.tokenPay.amount,
                        minValue: minValueBinding,
                        maxValue: .constant(nil),
                        minimumFractionDigits: .constant(nil),
                        fontPlaceHolder: .titleH4
                    )
                    .font(.titleH4)
                    .foregroundStyle(.colorBaseTent)
                    .focused($focusedField, equals: .pay)
                }
                Spacer(minLength: 0)
                HStack(alignment: .center, spacing: .md) {
                    TokenLogoView(
                        currencySymbol: viewModel.tokenPay.token.currencySymbol,
                        tokenName: viewModel.tokenPay.token.tokenName,
                        isVerified: viewModel.tokenPay.token.isVerified,
                        size: .init(width: 24, height: 24)
                    )
                    Text(viewModel.tokenPay.adaName)
                        .lineLimit(1)
                        .font(.labelMediumSecondary)
                        .foregroundStyle(.colorBaseTent)
                    Image(.icDown)
                        .resizable()
                        .renderingMode(.template)
                        .frame(width: 16, height: 16)
                        .tint(.colorBaseTent)
                }
                .padding(.md)
                .overlay(RoundedRectangle(cornerRadius: 20).fill(Color.colorSurfacePrimaryDefault))
                .contentShape(.rect)
                .onTapGesture {
                    hideKeyboard()
                    viewModel.action.send(.showSelectToken(isTokenPay: true))
                }
            }
            HStack(alignment: .center, spacing: 4) {
                if viewModel.tokenPay.subPrice > 0 {
                    Text(
                        viewModel.tokenPay.subPrice
                            .formatNumber(
                                prefix: Currency.usd.prefix,
                                roundingOffset: viewModel.tokenPay.token.decimals,
                                font: .paragraphSmall,
                                fontColor: .colorInteractiveTentPrimarySub
                            )
                    )
                }
                Spacer()
                Image(.icWallet)
                    .resizable()
                    .frame(width: 16, height: 16)
                Text(viewModel.tokenPay.token.amount.formatNumber(roundingOffset: nil, font: .paragraphSmall, fontColor: .colorInteractiveTentPrimarySub))
            }
        }
        .padding(.xl)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(focusedField == .pay ? .colorBorderPrimaryPressed : .colorBorderPrimarySub, lineWidth: focusedField == .pay ? 2 : 1)
        )
        .padding(.horizontal, .xl)
        .padding(.top, .lg)
    }
    
    @ViewBuilder
    private var tokenReceiveView: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("You receive")
                .font(.paragraphSmall)
                .foregroundStyle(.colorInteractiveTentPrimarySub)
            HStack(alignment: .center, spacing: 6) {
                if viewModel.isSwapExactIn && viewModel.isGettingTradeInfo {
                    HStack(spacing: 0) {
                        Text("")
                    }
                    .skeleton(with: true)
                    .frame(width: 124, height: 32)
                } else {
                    let minValueBinding = Binding<Double>(
                        get: { pow(10, Double(viewModel.tokenReceive.token.decimals) * -1) },
                        set: { _ in }
                    )
                    AmountTextField(
                        value: $viewModel.tokenReceive.amount,
                        minValue: minValueBinding,
                        maxValue: .constant(nil),
                        minimumFractionDigits: .constant(nil),
                        fontPlaceHolder: .titleH4
                    )
                    .font(.titleH4)
                    .foregroundStyle(.colorBaseTent)
                    .focused($focusedField, equals: .receive)
                    .disabled(true)
                }
                Spacer(minLength: 0)
                HStack(alignment: .center, spacing: .md) {
                    TokenLogoView(
                        currencySymbol: viewModel.tokenReceive.token.currencySymbol,
                        tokenName: viewModel.tokenReceive.token.tokenName,
                        isVerified: viewModel.tokenReceive.token.isVerified,
                        size: .init(width: 24, height: 24)
                    )
                    Text(viewModel.tokenReceive.adaName)
                        .lineLimit(1)
                        .font(.labelMediumSecondary)
                        .foregroundStyle(.colorBaseTent)
                    Image(.icDown)
                        .resizable()
                        .renderingMode(.template)
                        .frame(width: 16, height: 16)
                        .tint(.colorBaseTent)
                }
                .padding(.md)
                .overlay(RoundedRectangle(cornerRadius: 20).fill(Color.colorSurfacePrimaryDefault))
                .onTapGesture {
                    hideKeyboard()
                    viewModel.action.send(.showSelectToken(isTokenPay: false))
                }
            }
            HStack(alignment: .center, spacing: 4) {
                if viewModel.tokenReceive.subPrice > 0 {
                    Text(
                        viewModel.tokenReceive.subPrice
                            .formatNumber(
                                prefix: Currency.usd.prefix,
                                roundingOffset: viewModel.tokenReceive.token.decimals,
                                font: .paragraphSmall,
                                fontColor: .colorInteractiveTentPrimarySub
                            )
                    )
                }
                Spacer()
                Image(.icWallet)
                    .resizable()
                    .frame(width: 16, height: 16)
                Text(viewModel.tokenReceive.token.amount.formatNumber(roundingOffset: nil, font: .paragraphSmall, fontColor: .colorInteractiveTentPrimarySub))
            }
        }
        .padding(.xl)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(focusedField == .receive ? .colorBorderPrimaryPressed : .colorBorderPrimarySub, lineWidth: focusedField == .receive ? 2 : 1)
        )
        .padding(.horizontal, .xl)
        .padding(.top, .xs)
    }
    
    @ViewBuilder
    private var routingView: some View {
        if viewModel.iosTradeEstimate != nil {
            HStack(alignment: .center, spacing: 4) {
                Text("Your Route")
                    .lineLimit(1)
                    .font(.paragraphXSmall)
                    .foregroundStyle(.colorInteractiveTentPrimarySub)
                Spacer(minLength: 0)
                if viewModel.isGettingTradeInfo {
                    HStack(spacing: 0) {
                        Text("")
                    }
                    .skeleton(with: true)
                    .frame(width: 56, height: 16)
                } else if let paths = viewModel.iosTradeEstimate?.paths, !paths.isEmpty {
                    let splits = paths.count > 1 ? "\(paths.count) splits" : "\(paths.count) split"
                    Text(splits)
                        .font(.paragraphSemi)
                        .foregroundStyle(.colorInteractiveToneHighlight)
                    Image(.icArrowRight)
                }
            }
            .padding(.horizontal, .xl)
            .frame(height: 52)
            .overlay(RoundedRectangle(cornerRadius: 12).stroke(.colorBorderPrimarySub, lineWidth: 1))
            .padding(.top, .md)
            .padding(.horizontal, .xl)
            .contentShape(.rect)
            .onTapGesture {
                guard !viewModel.isGettingTradeInfo else { return }
                guard let paths = viewModel.iosTradeEstimate?.paths, !paths.isEmpty else { return }
                hideKeyboard()
                $viewModel.isShowRouting.showSheet()
            }
        }
    }
    
    private var descriptionView: some View {
        HStack(alignment: .center, spacing: 4) {
            Text("Swaps are executed by third-party Cardano protocols.")
                .lineLimit(1)
                .font(.paragraphXSmall)
                .foregroundStyle(.colorBaseTent)
            Spacer(minLength: 0)
            
            Image(.icArrowDown)
        }
        .frame(height: 40)
        .padding(.horizontal, .lg)
        .overlay(RoundedRectangle(cornerRadius: .xl).fill(Color.colorSurfaceHighlightDefault))
        .padding(.top, .md)
        .padding(.horizontal, .xl)
        .contentShape(.rect)
        .onTapGesture {
            isShowDescView = true
        }
    }
    
    @ViewBuilder
    private var bottomView: some View {
        let payAmount = viewModel.tokenPay.amount.doubleValue
        let receiveAmount = viewModel.tokenReceive.amount.doubleValue
        if !payAmount.isZero && !receiveAmount.isZero {
            Color.colorBorderPrimarySub.frame(height: 1)
            HStack(alignment: .center, spacing: 8) {
                Circle().frame(width: 6, height: 6)
                    .foregroundStyle(.colorBaseSuccess)
                let rate: Double = !viewModel.isConvertRate ? (receiveAmount / payAmount) : (payAmount / receiveAmount)
                let firstAtt = AttributedString("1 \(!viewModel.isConvertRate ? viewModel.tokenPay.token.adaName : viewModel.tokenReceive.token.adaName) = ").build(font: .paragraphSmall, color: .colorInteractiveTentPrimarySub)
                let attribute = rate.formatNumber(suffix: viewModel.isConvertRate ? viewModel.tokenPay.token.adaName : viewModel.tokenReceive.token.adaName, font: .paragraphSmall, fontColor: .colorInteractiveTentPrimarySub)
                Text(firstAtt + attribute)
                    .frame(height: 22)
                Image(.icExecutePrice)
                    .fixSize(.xl)
                    .onTapGesture {
                        viewModel.isConvertRate.toggle()
                    }
                Spacer(minLength: 0)
                if let iosTradeEstimate = viewModel.iosTradeEstimate {
                    let priceImpact = iosTradeEstimate.avgPriceImpact
                    let priceImpactColor = iosTradeEstimate.priceImpactColor
                    Text(priceImpact.formatSNumber(maximumFractionDigits: 4) + "%")
                        .font(.paragraphXMediumSmall)
                        .foregroundStyle(priceImpactColor.0)
                        .padding(.horizontal, .md)
                        .frame(height: 20)
                        .background(
                            RoundedRectangle(cornerRadius: BorderRadius.full).fill(priceImpactColor.1)
                        )
                        .containerShape(.rect)
                        .onTapGesture {
                            hideKeyboard()
                            $viewModel.isShowInfo.showSheet()
                        }
                } else {
                    Text("--%")
                        .font(.paragraphXMediumSmall)
                        .foregroundStyle(.colorInteractiveToneSuccess)
                        .padding(.horizontal, .md)
                        .frame(height: 20)
                        .background(
                            RoundedRectangle(cornerRadius: BorderRadius.full).fill(.colorSurfaceSuccess)
                        )
                        .containerShape(.rect)
                        .onTapGesture {
                            hideKeyboard()
                            $viewModel.isShowInfo.showSheet()
                        }
                }
                HStack(alignment: .center) {
                    Image(.icNext)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 10, height: 10)
                        .rotationEffect(.degrees(-90))
                }
                .frame(height: 22)
                .containerShape(.rect)
                .onTapGesture {
                    hideKeyboard()
                    $viewModel.isShowInfo.showSheet()
                }
            }
            .padding(.xl)
        }
        if viewModel.showUnderstandingCheckbox {
            HStack(alignment: .center, spacing: 8) {
                Image(viewModel.understandingWarning ? .icSquareCheckBox : .icSquareUncheckBox)
                    .resizable()
                    .frame(width: 20, height: 20)
                Text("I understand these warnings")
                    .font(.paragraphSmall)
                    .foregroundStyle(.colorBaseTent)
                    .frame(maxWidth: .infinity, alignment: .leading)
                Spacer(minLength: 0)
            }
            .padding(.horizontal, .xl)
            .contentShape(.rect)
            .onTapGesture {
                viewModel.understandingWarning.toggle()
            }
        }
    }
    
    @ViewBuilder
    private var warningView: some View {
        if !viewModel.warningInfo.isEmpty {
            VStack(spacing: 0) {
                ForEach(Array(viewModel.warningInfo.enumerated()), id: \.offset) { index, warningInfo in
                    let isExpand = Binding<Bool>(
                        get: { (self.viewModel.isExpand[warningInfo] ?? false) == true },
                        set: { isExpand in
                            self.viewModel.isExpand[warningInfo] = isExpand
                        }
                    )
                    WarningItemView(waringInfo: warningInfo, isExpand: isExpand)
                }
            }
            .background(.colorSurfaceWarningDefault)
            .cornerRadius(12)
            .overlay(RoundedRectangle(cornerRadius: 12).stroke(.colorBorderWarningSub, lineWidth: 1))
            .padding(.horizontal, .xl)
            .padding(.bottom, .xl)
            .padding(.top, .md)
        }
    }
    
    private func processingSwapToken() {
        hideKeyboard()
        guard !viewModel.isGettingTradeInfo, viewModel.errorInfo == nil, viewModel.iosTradeEstimate != nil else { return }
        guard !viewModel.tokenPay.amount.doubleValue.isZero, !viewModel.tokenReceive.amount.doubleValue.isZero else { return }
        Task {
            do {
                viewModel.action.send(.cancelTimeInterval)
                switch appSetting.authenticationType {
                case .biometric:
                    try await BiometricAuthentication.authenticateUser()
                    swapTokenSuccess()
                case .password:
                    $isShowSignContract.showSheet()
                }
            } catch {
                viewModel.action.send(.startTimeInterval)
                bannerState.showBannerError(error)
            }
        }
    }
    
    private func swapTokenSuccess() {
        Task {
            do {
                hudState.showLoading(true)
                let txRaw = try await viewModel.swapToken()
                let finalID = try await TokenManager.finalizeAndSubmitV2(txRaw: txRaw)
                hudState.showLoading(false)
                bannerState.infoContent = {
                    bannerState.infoContentDefault(onViewTransaction: {
                        finalID?.viewTransaction()
                    })
                }
                bannerState.showBanner(isShow: true)
                viewModel.action.send(.resetSwap)
            } catch {
                hudState.showLoading(false)
                bannerState.showBannerError(error.rawError)
                viewModel.action.send(.startTimeInterval)
            }
        }
    }
}

#Preview {
    SwapTokenView(viewModel: SwapTokenViewModel(tokenReceive: nil))
        .environmentObject(HUDState())
        .environmentObject(AppSetting.shared)
        .environmentObject(BannerState())
}


struct WarningItemView: View {
    let waringInfo: SwapTokenViewModel.WarningInfo
    @Binding
    var isExpand: Bool
    
    init(waringInfo: SwapTokenViewModel.WarningInfo, isExpand: Binding<Bool>) {
        self.waringInfo = waringInfo
        self._isExpand = isExpand
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack(spacing: Spacing.md) {
                Image(.icWarningYellow)
                    .resizable()
                    .rotationEffect(.degrees(180))
                    .frame(width: 16, height: 16)
                Text(waringInfo.title)
                    .font(.paragraphXMediumSmall)
                    .foregroundStyle(.colorInteractiveToneWarning)
                Spacer()
                Image(.icArrowDown)
                    .resizable()
                    .rotationEffect(.degrees(isExpand ? -180 : 0))
                    .frame(width: 16, height: 16)
            }
            .padding(.top, .md)
            if isExpand {
                Text(waringInfo.content)
                    .font(.paragraphXSmall)
                    .lineSpacing(2)
                    .foregroundStyle(.colorBaseTent)
                    .padding(.top, .xs)
            }
            Color.colorBorderPrimarySub.frame(height: 1)
                .padding(.top, .md)
            /*
            if showBottomLine {
                Color.colorBorderPrimarySub.frame(height: 1)
                    .padding(.top, .md)
            } else {
                Color.clear.frame(height: 1)
                    .padding(.top, .md)
            }
             */
        }
        .padding(.horizontal, .md)
        .contentShape(.rect)
        .onTapGesture {
            //withAnimation {
            isExpand.toggle()
            //}
        }
    }
}
