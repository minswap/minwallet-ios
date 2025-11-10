import SwiftUI
import FlowStacks


struct MainCoordinator: View {
    @StateObject
    private var viewModel = MainCoordinatorViewModel()
    @EnvironmentObject
    private var appSetting: AppSetting
    @EnvironmentObject
    private var bannerState: BannerState
    @EnvironmentObject
    private var hudState: HUDState

    var body: some View {
        FlowStack($viewModel.routes, withNavigation: true) {
            SplashView()
                .flowDestination(for: MainCoordinatorViewModel.Screen.self) { screen in
                    switch screen {
                    case .home:
                        HomeView().navigationBarHidden(true)
                    case let .policy(screenType):
                        PolicyConfirmView(screenType: screenType).navigationBarHidden(true)
                    case .gettingStarted:
                        GettingStartedView().navigationBarHidden(true)
                    case let .tokenDetail(token):
                        TokenDetailView(viewModel: TokenDetailViewModel(token: token)).navigationBarHidden(true)
                    case .about:
                        AboutView().navigationBarHidden(true)
                    case .changePassword:
                        ChangePasswordView(screenType: .setting).navigationBarHidden(true)
                    case let .changePasswordSuccess(screenType):
                        ChangePasswordSuccessView(screenType: screenType).navigationBarHidden(true)
                    case let .forgotPassword(screenType):
                        ForgotPasswordView(screenType: .changeYourPassword(screenType)).navigationBarHidden(true)
                    case let .createWallet(screen):
                        switch screen {
                        case .createWallet:
                            CreateNewWalletView().navigationBarHidden(true)
                        case .seedPhrase:
                            SensitiveView { 
                                CreateNewWalletSeedPhraseView()
                            }
                            .navigationBarHidden(true)
                        case let .reInputSeedPhrase(seedPhrase):
                            ReInputSeedPhraseView(screenType: .createWallet(seedPhrase: seedPhrase)).navigationBarHidden(true)
                        case let .setupNickName(seedPhrase):
                            SetupNickNameView(screenType: .createWallet(seedPhrase: seedPhrase)).navigationBarHidden(true)
                        case let .biometricSetup(seedPhrase, nickName):
                            BiometricSetupView(screenType: .createWallet(seedPhase: seedPhrase, nickName: nickName)).navigationBarHidden(true)
                        case let .createNewPassword(seedPhrase, nickName):
                            CreateNewPasswordView(screenType: .createWallet(seedPhrase: seedPhrase, nickName: nickName)).navigationBarHidden(true)
                        case .createNewWalletSuccess:
                            CreateNewWalletSuccessView(screenType: .newWallet).navigationBarHidden(true)
                        }

                    case let .restoreWallet(screen):
                        switch screen {
                        case .restoreWallet:
                            RestoreWalletView().navigationBarHidden(true)
                        case .seedPhrase:
                            ReInputSeedPhraseView(screenType: .restoreWallet).navigationBarHidden(true)
                        case let .setupNickName(fileContent, seedPhrase):
                            SetupNickNameView(screenType: .restoreWallet(fileContent: fileContent, seedPhrase: seedPhrase)).navigationBarHidden(true)
                        case .createNewWalletSuccess:
                            CreateNewWalletSuccessView(screenType: .restoreWallet).navigationBarHidden(true)
                        case let .createNewPassword(fileContent, seedPhrase, nickName):
                            CreateNewPasswordView(screenType: .restoreWallet(fileContent: fileContent, seedPhrase: seedPhrase, nickName: nickName)).navigationBarHidden(true)
                        case .importFile:
                            RestoreWalletImportFileView().navigationBarHidden(true)
                        case let .biometricSetup(fileContent, seedPhrase, nickName):
                            BiometricSetupView(screenType: .restoreWallet(fileContent: fileContent, seedPhase: seedPhrase, nickName: nickName)).navigationBarHidden(true)
                        }

                    case let .walletSetting(screen):
                        switch screen {
                        case .walletAccount:
                            WalletAccountView().navigationBarHidden(true)
                        case .changePassword:
                            ChangePasswordView(screenType: .walletSetting).navigationBarHidden(true)
                        case .changePasswordSuccess:
                            ChangePasswordSuccessView(screenType: .walletSetting).navigationBarHidden(true)
                        case .editNickName:
                            SetupNickNameView(screenType: .walletSetting).navigationBarHidden(true)
                        }

                    case let .sendToken(screen):
                        switch screen {
                        case let .sendToken(tokenSelected, isSendAll, screenType):
                            SendTokenView(viewModel: SendTokenViewModel(tokens: tokenSelected, isSendAll: isSendAll, screenType: screenType)).navigationBarHidden(true)
                        case let .toWallet(tokens, sendAll):
                            ToWalletAddressView(viewModel: ToWalletAddressViewModel(tokens: tokens, isSendAll: sendAll)).navigationBarHidden(true)
                        case let .confirm(tokens, address, sendAll):
                            ConfirmSendTokenView(viewModel: ConfirmSendTokenViewModel(tokens: tokens, address: address, isSendAll: sendAll)).navigationBarHidden(true)
                        case let .selectToken(tokensSelected, screenType, sourceScreenType, onSelectToken):
                            SelectTokenView(viewModel: SelectTokenViewModel(tokensSelected: tokensSelected, screenType: screenType, sourceScreenType: sourceScreenType), onSelectToken: onSelectToken)
                                .navigationBarHidden(true)
                        }

                    case let .receiveToken(screenType):
                        ReceiveTokenView(screenType: screenType).navigationBarHidden(true)

                    case let .swapToken(screen):
                        switch screen {
                        case let .swapToken(token):
                            SwapTokenView(viewModel: SwapTokenViewModel(tokenReceive: token)).navigationBarHidden(true)
                        }

                    case .searchToken:
                        SearchTokenView().navigationBarHidden(true)

                    case let .securitySetting(screen):
                        switch screen {
                        case .authentication:
                            AuthenticationSettingView().navigationBarHidden(true)
                        case let .createPassword(onCreatePassSuccess):
                            CreateNewPasswordView(
                                screenType: .authenticationSetting,
                                onCreatePasswordSuccess: { password in
                                    onCreatePassSuccess.onCreatePassSuccess?(password)
                                }
                            )
                            .navigationBarHidden(true)
                        case .forgotPassword:
                            ForgotPasswordView(screenType: .enterPassword).navigationBarHidden(true)
                        }
                    case let .orderHistoryDetail(wrapOrder, onReloadOrder):
                        OrderHistoryDetailView(
                            wrapOrder: wrapOrder,
                            order: wrapOrder.orders.first ?? .init(),
                            ordersCancel: wrapOrder.orders.filter { $0.status == .created },
                            onReloadOrder: onReloadOrder
                        )
                        .navigationBarHidden(true)
                    case .orderHistory:
                        OrderHistoryView().navigationBarHidden(true)
                    case .scanQR:
                        ScanQRView().navigationBarHidden(true)
                    case .termOfService:
                        TermOfServiceView().navigationBarHidden(true)
                    }
                }
                .navigationBarHidden(true)
                .environment(\.locale, .init(identifier: appSetting.language))
        }
        .alert(isPresented: $hudState.isPresented) {
            Alert(
                title: Text(hudState.title), message: Text(hudState.msg),
                dismissButton: .default(
                    Text(hudState.okTitle),
                    action: {
                        hudState.onAction?()
                    }))
        }
        .banner(
            isShowing: $bannerState.isShowingBanner,
            infoContent: {
                if let infoContent = bannerState.infoContent {
                    infoContent()
                } else {
                    EmptyView()
                }
            }
        )
        .progressView(isShowing: $hudState.isShowLoading)
    }
}

#Preview {
    MainCoordinator()
        .environmentObject(AppSetting.shared)
}
