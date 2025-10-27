import SwiftUI
import FlowStacks


struct EnterYourPasswordView: View {
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
    private var password: String = ""
    @FocusState
    var isFocus: Bool
    @Binding
    var authenticationType: AppSetting.AuthenticationType
    @State
    private var isShowIncorrectPassword: Bool = false
    @Environment(\.partialSheetDismiss)
    private var onDismiss
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("Enter your password")
                .font(.titleH5)
                .frame(maxWidth: .infinity, alignment: .leading)
                .frame(height: 60)
            VStack(spacing: 4) {
                Text("Password")
                    .font(.labelSmallSecondary)
                    .foregroundStyle(.colorBaseTent)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.top, .lg)
                let strokeColor: Color = isShowIncorrectPassword ? Color.colorBorderDangerDefault : (isFocus ? .colorBorderPrimaryPressed : .colorBorderPrimaryDefault)
                SecurePasswordTextField(placeHolder: "Enter your password", text: $password)
                    .focused($isFocus)
                    .frame(height: 44)
                    .overlay(
                        RoundedRectangle(cornerRadius: BorderRadius.full)
                            .stroke(strokeColor, lineWidth: isFocus ? 2 : 1)
                    )
                    .onChange(
                        of: password,
                        perform: { newValue in
                            isShowIncorrectPassword = false
                        })
                if isShowIncorrectPassword {
                    HStack(spacing: 4) {
                        Image(.icWarning)
                            .fixSize(16)
                        Text("Incorrect password")
                            .font(.paragraphSmall)
                            .foregroundStyle(.colorInteractiveDangerTent)
                        Spacer()
                    }
                    .padding(.top, .md)
                }
            }
            Button(
                action: {
                    onDismiss?()
                    navigator.push(.securitySetting(.forgotPassword))
                },
                label: {
                    Text("Forgot password?")
                        .font(.paragraphSemi)
                        .foregroundStyle(.colorInteractiveToneHighlight)
                }
            )
            .buttonStyle(.plain)
            .padding(.top, .xl)
            .padding(.bottom, 40)
            let combinedBinding = Binding<Bool>(
                get: { !password.isBlank },
                set: { _ in }
            )
            CustomButton(title: "Confirm", isEnable: combinedBinding) {
                let currentPassword: String = (try? AppSetting.getPasswordFromKeychain(username: AppSetting.USER_NAME)) ?? ""
                guard currentPassword == password
                else {
                    isShowIncorrectPassword = true
                    return
                }
                hideKeyboard()
                Task {
                    do {
                        switch authenticationType {
                        case .biometric:
                            try await appSetting.reAuthenticateUser()
                            guard let minWallet = userInfo.minWallet else { return }
                            guard verifyPassword(wallet: minWallet, password: currentPassword) else { return }
                            guard let newWallet = changePassword(wallet: minWallet, currentPassword: currentPassword, newPassword: MinWalletConstant.passDefaultForFaceID)
                            else {
                                throw AppGeneralError.localErrorLocalized(message: "Something went wrong!")
                            }
                            userInfo.saveWalletInfo(walletInfo: newWallet)
                        case .password:
                            break
                        }
                        onDismiss?()
                        appSetting.authenticationType = authenticationType
                    } catch {
                        bannerState.showBannerError(error.localizedDescription)
                    }
                }
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
        EnterYourPasswordView(authenticationType: .constant(.password))
        Spacer()
    }
}
