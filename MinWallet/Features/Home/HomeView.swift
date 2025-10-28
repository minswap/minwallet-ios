import SwiftUI
import FlowStacks
import OneSignalFramework
import ObjectMapper
import SwiftyJSON


struct HomeView: View {
    @StateObject
    private var viewModel: HomeViewModel = .init()
    @EnvironmentObject
    private var navigator: FlowNavigator<MainCoordinatorViewModel.Screen>
    @EnvironmentObject
    private var userInfo: UserInfo
    @EnvironmentObject
    private var appSetting: AppSetting
    @StateObject
    private var tokenManager: TokenManager = TokenManager.shared
    @State
    private var isShowAppearance: Bool = false
    @State
    private var isShowTimeZone: Bool = false
    @State
    private var isShowCurrency: Bool = false
    @State
    private var isShowLanguage: Bool = false
    @State
    private var showSideMenu: Bool = false
    @State
    private var isCopyAddress: Bool = false
    @State
    private var isPresentAlertPermission: Bool = false
    @State
    private var openAppSetting: Bool = false

    var body: some View {
        ZStack {
            Color.colorBaseBackground.ignoresSafeArea()
            VStack(alignment: .leading, spacing: .zero) {
                headerView
                ScrollView {
                    VStack(alignment: .leading, spacing: .zero) {
                        walletAddressView
                        bannerAndActionView
                        TokenListView(viewModel: viewModel)
                            .environmentObject(tokenManager)
                            .padding(.top, .xl)
                    }
                }
                Spacer()
                CustomButton(title: "Swap") {
                    navigator.push(.swapToken(.swapToken(token: nil)))
                }
                .frame(height: 56)
                .padding(.horizontal, .xl)
                .safeAreaInset(edge: .bottom) {
                    Color.clear.frame(height: 0)
                }
            }
        }
        .sideMenu(isShowing: $showSideMenu) {
            SettingView(
                isShowAppearance: $isShowAppearance,
                isShowTimeZone: $isShowTimeZone,
                isShowCurrency: $isShowCurrency,
                isShowLanguage: $isShowLanguage,
                isPresentAlertPermission: $isPresentAlertPermission
            )
        }
        .presentSheet(isPresented: $isShowAppearance) {
            AppearanceView()
                .padding(.horizontal, .md)
                .padding(.vertical, .md)
        }
        .presentSheet(isPresented: $isShowCurrency) {
            CurrencyView()
                .padding(.horizontal, .md)
                .padding(.vertical, .md)
        }
        .presentSheet(isPresented: $isShowLanguage) {
            LanguageView()
        }
        .presentSheet(isPresented: $isShowTimeZone) {
            TimeZoneView()
                .padding(.horizontal, .md)
                .padding(.vertical, .md)
        }
        .onFirstAppear {
            Task {
                let firstRequest = OneSignal.Notifications.canRequestPermission
                if appSetting.enableNotification {
                    OneSignal.Notifications.requestPermission(
                        { accepted in
                            if firstRequest {
                                appSetting.enableNotification = accepted
                            } else if !accepted {
                                isPresentAlertPermission = true
                            }
                        }, fallbackToSettings: false)
                }
            }
        }
        .onOpenURL { incomingURL in
            //https://testnet-preprod.minswap.org/orders?s=83ada93f2ecadf5bbff265d36ae14303b5e19303f5ae107629ebf1961a7e7f98
            handleIncomingURL(incomingURL)
        }
        .onAppear {
            appSetting.swipeEnabled = false
        }
        .onDisappear {
            appSetting.swipeEnabled = true
        }
        .alert(isPresented: $isPresentAlertPermission) {
            Alert(
                title: Text("Open Settings"), message: Text("You currently have notifications turned off for this application. You can open Setting to re-enable them."),
                primaryButton: Alert.Button.default(
                    Text("Cancel"),
                    action: {
                        appSetting.enableNotification = false
                    }),
                secondaryButton: Alert.Button.default(
                    Text("Open Settings").foregroundColor(.red),
                    action: {
                        openAppSetting = true
                        openAppNotificationSettings()
                    }))
        }
        .onReceive(NotificationCenter.default.publisher(for: UIApplication.didBecomeActiveNotification)) { _ in
            guard openAppSetting else { return }
            openAppSetting = false
            if appSetting.enableNotification {
                appSetting.enableNotification = OneSignal.Notifications.permission
            }
        }
    }

    private var headerView: some View {
        HStack(spacing: .md) {
            ZStack {
                Image(.icAvatarDefault)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 40, height: 40)
                    .clipShape(Circle())

                Image(.icSubAvatar)
                    .resizable()
                    .frame(width: 14, height: 14)
                    .position(x: 35, y: 35)
            }
            .frame(width: 40, height: 40)
            .onTapGesture {
                withAnimation {
                    showSideMenu = true
                }
            }
            VStack(alignment: .leading, spacing: 2) {
                if !userInfo.adaHandleName.isBlank {
                    HStack(alignment: .center, spacing: .xs) {
                        Image(.icAdahandle)
                            .resizable()
                            .frame(width: 16, height: 16)
                            .padding(.leading, -2)
                        Text(userInfo.adaHandleName)
                            .font(.labelMediumSecondary)
                            .foregroundStyle(.colorInteractiveToneHighlight)
                            .lineLimit(1)
                    }
                } else {
                    Text(userInfo.walletName)
                        .font(.labelMediumSecondary)
                        .foregroundStyle(.colorBaseTent)
                        .lineLimit(1)
                }
                HStack(spacing: 4) {
                    Text(userInfo.minWallet?.address.shortenAddress)
                        .font(.paragraphXSmall)
                        .foregroundStyle(isCopyAddress ? .colorBaseSuccess : .colorInteractiveTentPrimarySub)
                    if isCopyAddress {
                        Image(.icCheckMark)
                            .resizable()
                            .renderingMode(.template)
                            .foregroundStyle(.colorBaseSuccess)
                            .frame(width: 16, height: 16)
                    } else {
                        Image(.icCopy)
                            .resizable()
                            .scaledToFill()
                            .frame(width: 16, height: 16)
                    }
                }
                .contentShape(.rect)
                .onTapGesture {
                    UIPasteboard.general.string = userInfo.minWallet?.address
                    withAnimation {
                        isCopyAddress = true
                    }
                    DispatchQueue.main.asyncAfter(
                        deadline: .now() + .seconds(2),
                        execute: {
                            withAnimation {
                                self.isCopyAddress = false
                            }
                        })
                }
            }
            .padding(.leading, .xs)

            Spacer(minLength: 0)
            Image(.icQrCode)
                .resizable()
                .scaledToFill()
                .padding(8)
                .frame(width: 40, height: 40)
                .clipShape(Circle())
                .overlay(
                    Circle()
                        .stroke(Color.colorBorderPrimaryTer, lineWidth: 1)
                )
                .contentShape(.rect)
                .onTapGesture {
                    navigator.push(.scanQR)
                }
            Image(.icSearch)
                .resizable()
                .scaledToFill()
                .padding(8)
                .frame(width: 40, height: 40)
                .clipShape(Circle())
                .overlay(
                    Circle()
                        .stroke(Color.colorBorderPrimaryTer, lineWidth: 1)
                )
                .contentShape(.rect)
                .onTapGesture {
                    navigator.push(.searchToken)
                }
        }
        .padding(.horizontal, .xl)
        .padding(.top, .xs)
        .padding(.bottom, .md)
    }

    private var walletAddressView: some View {
        VStack(alignment: .leading, spacing: 4) {
            let prefix: String = appSetting.currency == Currency.usd.rawValue ? Currency.usd.prefix : ""
            let suffix: String = appSetting.currency == Currency.ada.rawValue ? " \(Currency.ada.prefix)" : ""
            HStack(alignment: .firstTextBaseline, spacing: 0) {
                //let netValue: Double = appSetting.currency == Currency.ada.rawValue ? tokenManager.netAdaValue : (tokenManager.netAdaValue * appSetting.currencyInADA)
                let netValue: Double = tokenManager.netAdaValue
                let netValueString: String = netValue.formatSNumber(maximumFractionDigits: 2)
                let components = netValueString.split(separator: ".")
                Text(prefix + String(components.first ?? ""))
                    .font(.titleH3)
                    .foregroundStyle(.colorBaseTent)
                    .minimumScaleFactor(0.01)
                    .lineLimit(1)
                if components.count > 1 {
                    Text(".\(components[1])" + suffix)
                        .font(.titleH5)
                        .foregroundStyle(.colorInteractiveTentPrimaryDisable)
                        .lineLimit(1)
                        .minimumScaleFactor(0.01)
                } else {
                    Text(suffix)
                        .font(.titleH5)
                        .foregroundStyle(.colorInteractiveTentPrimaryDisable)
                        .lineLimit(1)
                        .minimumScaleFactor(0.01)
                }
            }
            if !tokenManager.adaValue.isZero {
                HStack(spacing: 4) {
                    let pnl24H: Double = tokenManager.adaValue
                    let foregroundStyle: Color = pnl24H > 0 ? .colorBaseSuccess : .colorBorderDangerDefault
                    Text("\(prefix)\(pnl24H.formatSNumber(maximumFractionDigits: 2))\(suffix)")
                        .font(.paragraphSmall)
                        .foregroundStyle(foregroundStyle)
                    Circle().frame(width: 4, height: 4)
                        .foregroundStyle(.colorBaseTent)
                    Text(abs(tokenManager.pnl24HPercent).formatSNumber(maximumFractionDigits: 2) + "%")
                        .font(.paragraphSmall)
                        .foregroundStyle(foregroundStyle)
                    if !tokenManager.adaValue.isZero {
                        Image(tokenManager.adaValue > 0 ? .icUp : .icDown)
                            .resizable()
                            .frame(width: 16, height: 16)
                    }
                }
            }
        }
        .padding(.horizontal, .xl)
        .padding(.top, .lg)
        .padding(.bottom, .lg)
    }

    @ViewBuilder
    private var bannerAndActionView: some View {
        HStack(spacing: Spacing.md) {
            CustomButton(
                title: "Receive",
                icon: .icReceive
            ) {
                navigator.push(.receiveToken(.home))
            }
            .frame(height: 44)
            CustomButton(
                title: "Send",
                variant: .secondary,
                icon: .icSend
            ) {
                navigator.push(.sendToken(.selectToken(tokensSelected: [], screenType: .initSelectedToken, sourceScreenType: .normal, onSelectToken: nil)))
            }
            .frame(height: 44)
            CustomButton(
                title: "Orders",
                variant: .secondary,
                icon: .icOrderHistory
            ) {
                navigator.push(.orderHistory)
            }
            .frame(height: 44)
        }
        .padding(.vertical, Spacing.md)
        .padding(.horizontal, Spacing.xl)
        /*
        CarouselView(homeViewModel: viewModel, tokenManager: tokenManager)
            .frame(height: 98)
            .padding(.top, Spacing.xl)
            .padding(.bottom, Spacing.md)
            .padding(.horizontal, Spacing.xl)
         */
    }

    private func handleIncomingURL(_ url: URL) {
        //guard url.scheme == MinWalletConstant.minswapScheme else { return }
        guard let components = URLComponents(url: url, resolvingAgainstBaseURL: true) else { return }

        switch components.path {
        case "/orders":
            guard let orderID = components.queryItems?.first(where: { $0.name == "s" })?.value
            else {
                navigator.push(.orderHistory)
                return
            }

            fetchOrderDetail(
                order: orderID,
                fallback: {
                    navigator.push(.orderHistory)
                })
        default:
            break
        }
    }
}

extension HomeView {
    private func fetchOrderDetail(order: String, fallback: (() -> Void)?) {
        guard let address = userInfo.minWallet?.address, !address.isEmpty else { return }
        Task {
            let input = OrderHistory.Request()
                .with {
                    $0.ownerAddress = address
                    $0.txId = order
                }

            do {
                let jsonData = try await OrderAPIRouter.getOrders(request: input).async_request()
                let orders = Mapper<OrderHistory>().gk_mapArrayOrNull(JSONObject: JSON(jsonData)["orders"].arrayValue)
                guard let order = orders?.first
                else {
                    fallback?()
                    return
                }
                navigator.push(.orderHistoryDetail(wrapOrder: WrapOrderHistory(orders: [order], key: order.createdTxId), onReloadOrder: nil))
            } catch {
                fallback?()
            }
        }
    }
}


#Preview {
    HomeView()
        .environmentObject(AppSetting.shared)
        .environmentObject(UserInfo.shared)
}

extension UINavigationController: @retroactive UIGestureRecognizerDelegate {
    override open func viewDidLoad() {
        super.viewDidLoad()
        interactivePopGestureRecognizer?.delegate = self
    }

    public func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        if AppSetting.shared.swipeEnabled {
            return viewControllers.count > 1
        }
        return false
    }
}
