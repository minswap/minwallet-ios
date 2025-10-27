import SwiftUI
import FlowStacks


struct ChangePasswordView: View {
    enum ScreenType {
        case setting
        case walletSetting
    }
    
    enum FocusedField: Hashable {
        case oldPassword, password, rePassword
    }
    
    @EnvironmentObject
    var navigator: FlowNavigator<MainCoordinatorViewModel.Screen>
    @EnvironmentObject
    private var hudState: HUDState
    @EnvironmentObject
    private var userInfo: UserInfo
    @EnvironmentObject
    private var bannerState: BannerState
    @State
    private var oldPassword: String = ""
    @State
    private var password: String = ""
    @State
    private var rePassword: String = ""
    @FocusState
    private var focusedField: FocusedField?
    @State
    private var passwordValidationMatched: [PasswordValidation] = []
    @State
    private var currentPassword: String = ""
    @State
    var screenType: ScreenType
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("Change your password")
                .font(.titleH5)
                .foregroundStyle(.colorBaseTent)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.top, .lg)
                .padding(.bottom, .xl)
                .padding(.horizontal, .xl)
            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    VStack(spacing: 4) {
                        Text("Old Password")
                            .font(.labelSmallSecondary)
                            .foregroundStyle(.colorBaseTent)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.horizontal, .xl)
                            .padding(.top, .lg)
                        SecurePasswordTextField(placeHolder: "Enter old password", text: $oldPassword)
                            .focused($focusedField, equals: .oldPassword)
                            .frame(height: 44)
                            .overlay(
                                RoundedRectangle(cornerRadius: BorderRadius.full)
                                    .stroke(focusedField == .oldPassword ? .colorBorderPrimaryPressed : .colorBorderPrimaryDefault, lineWidth: focusedField == .oldPassword ? 2 : 1)
                            )
                            .padding(.horizontal, .xl)
                    }
                    if !oldPassword.isEmpty && currentPassword != oldPassword {
                        HStack(spacing: .xs) {
                            Image(.icWarning)
                                .resizable()
                                .frame(width: 16, height: 16)
                            Text("Password incorrect")
                                .font(.paragraphXSmall)
                                .foregroundStyle(.colorInteractiveToneDanger)
                            Spacer()
                        }
                        .padding(.horizontal, .xl)
                        .padding(.top, .md)
                    }
                    VStack(spacing: 4) {
                        Text("New Password")
                            .font(.labelSmallSecondary)
                            .foregroundStyle(.colorBaseTent)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.horizontal, .xl)
                            .padding(.top, .lg)
                        SecurePasswordTextField(placeHolder: "Enter new password", text: $password)
                            .focused($focusedField, equals: .password)
                            .frame(height: 44)
                            .overlay(
                                RoundedRectangle(cornerRadius: BorderRadius.full)
                                    .stroke(focusedField == .password ? .colorBorderPrimaryPressed : .colorBorderPrimaryDefault, lineWidth: focusedField == .password ? 2 : 1)
                            )
                            .padding(.horizontal, .xl)
                            .onChange(of: password) { newValue in
                                passwordValidationMatched = PasswordValidation.validateInput(password: newValue)
                            }
                    }
                    if !password.isEmpty {
                        VStack(spacing: 10) {
                            Text("Your password must contain:")
                                .font(.paragraphXSmall)
                                .foregroundStyle(.colorBaseTent)
                                .frame(maxWidth: .infinity, alignment: .leading)
                            ForEach(PasswordValidation.allCases) { validation in
                                HStack(spacing: .md) {
                                    Image(passwordValidationMatched.contains(validation) ? .icChecked : .icUnchecked)
                                        .resizable()
                                        .frame(width: 16, height: 16)
                                    Text(validation.rawValue)
                                        .font(.paragraphXSmall)
                                        .foregroundStyle(!passwordValidationMatched.contains(validation) ? .colorInteractiveTentPrimarySub : .colorBaseTent)
                                    Spacer()
                                }
                            }
                        }
                        .padding(.horizontal, .xl)
                        .padding(.top, .xl)
                    }
                    VStack(spacing: 4) {
                        Text("Confirm new password")
                            .font(.labelSmallSecondary)
                            .foregroundStyle(.colorBaseTent)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.horizontal, .xl)
                        SecurePasswordTextField(placeHolder: "Enter new password", text: $rePassword)
                            .focused($focusedField, equals: .rePassword)
                            .frame(height: 44)
                            .overlay(
                                RoundedRectangle(cornerRadius: BorderRadius.full)
                                    .stroke(focusedField == .rePassword ? .colorBorderPrimaryPressed : .colorBorderPrimaryDefault, lineWidth: focusedField == .rePassword ? 2 : 1)
                            )
                            .padding(.horizontal, .xl)
                            .ignoresSafeArea(.keyboard, edges: .bottom)
                    }
                    .padding(.top, .xl)
                    .padding(.bottom, rePassword.isEmpty ? .xl : .md)
                    if !rePassword.isEmpty {
                        HStack(spacing: .xs) {
                            Image(password == rePassword ? .icChecked : .icWarning)
                                .resizable()
                                .frame(width: 16, height: 16)
                            Text(password == rePassword ? "Password is match" : "Password is not match")
                                .font(.paragraphXSmall)
                                .foregroundStyle(password == rePassword ? .colorBaseSecond : .colorInteractiveToneDanger)
                            Spacer()
                        }
                        .padding(.horizontal, .xl)
                        .padding(.bottom, .xl)
                    }
                    Button(
                        action: {
                            navigator.push(.forgotPassword(screenType))
                        },
                        label: {
                            Text("Forgot password?")
                                .font(.paragraphSemi)
                                .foregroundStyle(.colorInteractiveToneHighlight)
                        }
                    )
                    .buttonStyle(.plain)
                    .padding(.horizontal, .xl)
                    .padding(.bottom, 40)
                }
            }
            Spacer()
            if focusedField == nil {
                let combinedBinding = Binding<Bool>(
                    get: { (passwordValidationMatched.count == PasswordValidation.allCases.count) && (password == rePassword) && !currentPassword.isEmpty },
                    set: { newValue in }
                )
                CustomButton(title: "Change", isEnable: combinedBinding) {
                    do {
                        guard let minWallet = userInfo.minWallet else { return }
                        guard verifyPassword(wallet: minWallet, password: currentPassword) else { return }
                        guard let newWallet = changePassword(wallet: minWallet, currentPassword: currentPassword, newPassword: password)
                        else {
                            throw AppGeneralError.localErrorLocalized(message: "Change password failed")
                        }
                        try AppSetting.savePasswordToKeychain(username: AppSetting.USER_NAME, password: password)
                        userInfo.saveWalletInfo(walletInfo: newWallet)
                        switch screenType {
                        case .setting:
                            navigator.push(.changePasswordSuccess(.setting))
                        case .walletSetting:
                            navigator.push(.changePasswordSuccess(.walletSetting))
                        }
                    } catch {
                        bannerState.showBannerError(error.localizedDescription)
                    }
                    
                }
                .frame(height: 56)
                .padding(.horizontal, .xl)
            }
        }
        .modifier(
            BaseContentView(
                screenTitle: " ",
                actionLeft: {
                    navigator.pop()
                })
        )
        .task {
            guard currentPassword.isEmpty else { return }
            currentPassword = (try? AppSetting.getPasswordFromKeychain(username: AppSetting.USER_NAME)) ?? ""
        }
    }
}

#Preview {
    ChangePasswordView(screenType: .setting)
        .environmentObject(AppSetting.shared)
}
