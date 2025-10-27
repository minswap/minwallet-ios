import SwiftUI
import FlowStacks


struct CreateNewPasswordView: View {
    enum ScreenType {
        case authenticationSetting
        case createWallet(seedPhrase: [String], nickName: String)
        case restoreWallet(fileContent: String, seedPhrase: [String], nickName: String)
    }
    enum FocusedField: Hashable {
        case password, rePassword
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
    private var password: String = ""
    @State
    private var rePassword: String = ""
    @FocusState
    private var focusedField: FocusedField?
    
    @State
    var screenType: ScreenType
    
    var onCreatePasswordSuccess: ((String) -> Void)?
    
    @State
    private var passwordValidationMatched: [PasswordValidation] = []
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("Create your password")
                .font(.titleH5)
                .foregroundStyle(.colorBaseTent)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.top, .lg)
                .padding(.bottom, .xl)
                .padding(.horizontal, .xl)
            ScrollView {
                VStack(spacing: 0) {
                    VStack(spacing: 4) {
                        Text("Password")
                            .font(.labelSmallSecondary)
                            .foregroundStyle(.colorBaseTent)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.horizontal, .xl)
                            .padding(.top, .lg)
                        SecurePasswordTextField(placeHolder: "Create new spending password", text: $password)
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
                    if !password.isEmpty && passwordValidationMatched.count != PasswordValidation.allCases.count {
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
                        Text("Confirm")
                            .font(.labelSmallSecondary)
                            .foregroundStyle(.colorBaseTent)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.horizontal, .xl)
                        SecurePasswordTextField(placeHolder: "Confirm spending password", text: $rePassword)
                            .focused($focusedField, equals: .rePassword)
                            .frame(height: 44)
                            .overlay(
                                RoundedRectangle(cornerRadius: BorderRadius.full)
                                    .stroke(focusedField == .rePassword ? .colorBorderPrimaryPressed : .colorBorderPrimaryDefault, lineWidth: focusedField == .rePassword ? 2 : 1)
                            )
                            .padding(.horizontal, .xl)
                    }
                    .padding(.vertical, .xl)
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
                    }
                }
            }
            
            Spacer()
            let combinedBinding = Binding<Bool>(
                get: { (passwordValidationMatched.count == PasswordValidation.allCases.count) && (password == rePassword) },
                set: { newValue in }
            )
            CustomButton(title: "Create", isEnable: combinedBinding) {
                switch screenType {
                case .authenticationSetting:
                    onCreatePasswordSuccess?(password)
                    navigator.pop()
                case let .createWallet(seedPhrase, nickName):
                    do {
                        let nickName = nickName.isBlank ? "My MinWallet" : nickName
                        let seedPhrase = seedPhrase.joined(separator: " ")
                        guard let wallet = createWallet(phrase: seedPhrase, password: password, networkEnv: MinWalletConstant.networkID, walletName: nickName)
                        else {
                            throw AppGeneralError.localErrorLocalized(message: "Error creating wallet")
                        }
                        try AppSetting.savePasswordToKeychain(username: AppSetting.USER_NAME, password: password)
                        appSetting.authenticationType = .password
                        appSetting.isLogin = true
                        userInfo.saveWalletInfo(walletInfo: wallet)
                        navigator.push(.createWallet(.createNewWalletSuccess))
                    } catch {
                        bannerState.showBannerError(error.localizedDescription)
                    }
                case let .restoreWallet(fileContent, seedPhrase, nickName):
                    do {
                        let nickName = nickName.isBlank ? "My MinWallet" : nickName
                        let wallet: MinWallet? = {
                            if !fileContent.isBlank {
                                importWallet(data: fileContent, password: password, walletName: nickName)
                            } else {
                                createWallet(phrase: seedPhrase.joined(separator: " "), password: password, networkEnv: MinWalletConstant.networkID, walletName: nickName)
                            }
                        }()
                        guard let wallet = wallet else { throw AppGeneralError.localErrorLocalized(message: "Error while restoring wallet") }
                        try AppSetting.savePasswordToKeychain(username: AppSetting.USER_NAME, password: password)
                        appSetting.authenticationType = .password
                        appSetting.isLogin = true
                        
                        userInfo.saveWalletInfo(walletInfo: wallet)
                        navigator.push(.restoreWallet(.createNewWalletSuccess))
                    } catch {
                        bannerState.showBannerError(error.localizedDescription)
                    }
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
                }))
    }
}

#Preview {
    CreateNewPasswordView(screenType: .authenticationSetting)
}
