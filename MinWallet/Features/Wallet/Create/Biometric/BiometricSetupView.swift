import SwiftUI
import FlowStacks


struct BiometricSetupView: View {
    enum ScreenType {
        case createWallet(seedPhase: [String], nickName: String)
        case restoreWallet(fileContent: String, seedPhase: [String], nickName: String)
    }
    
    @EnvironmentObject
    private var navigator: FlowNavigator<MainCoordinatorViewModel.Screen>
    @EnvironmentObject
    private var appSetting: AppSetting
    @EnvironmentObject
    private var userInfo: UserInfo
    @EnvironmentObject
    private var hudState: HUDState
    @EnvironmentObject
    private var bannerState: BannerState
    @State
    var screenType: ScreenType
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            VStack(alignment: .center, spacing: 16) {
                Image(.icFaceId)
                Text("Choose your best way to log-in")
                    .font(.titleH5)
                    .foregroundStyle(.colorBaseTent)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, .xl)
                Text("Please write down your 24 words seed phrase and store it in a secured place.")
                    .font(.paragraphSmall)
                    .foregroundStyle(.colorBaseTent)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, .xl)
            }
            .padding(.top, 24)
            Spacer()
            CustomButton(title: appSetting.biometricAuthentication.biometricType == .faceID ? "Use FaceID" : "Use TouchID") {
                Task {
                    do {
                        try await appSetting.reAuthenticateUser()
                        appSetting.authenticationType = .biometric
                        switch screenType {
                        case .createWallet(let seedPhrase, let nickName):
                            let seedPhrase = seedPhrase.joined(separator: " ")
                            let nickName = nickName.isBlank ? "My MinWallet" : nickName
                            guard let wallet = createWallet(phrase: seedPhrase, password: MinWalletConstant.passDefaultForFaceID, networkEnv: MinWalletConstant.networkID, walletName: nickName)
                            else {
                                throw AppGeneralError.localErrorLocalized(message: "Something went wrong!")
                            }
                            
                            try AppSetting.savePasswordToKeychain(username: AppSetting.USER_NAME, password: MinWalletConstant.passDefaultForFaceID)
                            userInfo.saveWalletInfo(walletInfo: wallet)
                            appSetting.isLogin = true

                        case let .restoreWallet(fileContent, seedPhrase, nickName):
                            let nickName = nickName.isBlank ? "My MinWallet" : nickName
                            let wallet: MinWallet? = {
                                if !fileContent.isBlank {
                                    return importWallet(data: fileContent, password: MinWalletConstant.passDefaultForFaceID, walletName: nickName)
                                } else {
                                    return createWallet(phrase: seedPhrase.joined(separator: " "), password: MinWalletConstant.passDefaultForFaceID, networkEnv: MinWalletConstant.networkID, walletName: nickName)
                                }
                            }()
                            guard let wallet = wallet else {
                                throw AppGeneralError.localErrorLocalized(message: "Error while restoring wallet")
                            }
                            
                            try AppSetting.savePasswordToKeychain(username: AppSetting.USER_NAME, password: MinWalletConstant.passDefaultForFaceID)
                            userInfo.saveWalletInfo(walletInfo: wallet)
                            appSetting.isLogin = true
                        }
                        navigator.push(.createWallet(.createNewWalletSuccess))
                    } catch {
                        bannerState.showBannerError(error.localizedDescription)
                        appSetting.authenticationType = .password
                    }
                }
            }
            .frame(height: 56)
            .padding(.horizontal, .xl)
            CustomButton(title: "Create password", variant: .secondary) {
                switch screenType {
                case .createWallet(let seedPhase, let nickName):
                    navigator.push(.createWallet(.createNewPassword(seedPhrase: seedPhase, nickName: nickName)))

                case .restoreWallet(let fileContent, let seedPhase, let nickName):
                    navigator.push(.restoreWallet(.createNewPassword(fileContent: fileContent, seedPhrase: seedPhase, nickName: nickName)))
                }
            }
            .frame(height: 56)
            .padding(.horizontal, .xl)
        }
        .modifier(
            BaseContentView(
                screenTitle: " ",
                actionLeft: {
                    navigator.pop()
                })
        )
    }
}

#Preview {
    BiometricSetupView(screenType: .createWallet(seedPhase: [], nickName: ""))
}
