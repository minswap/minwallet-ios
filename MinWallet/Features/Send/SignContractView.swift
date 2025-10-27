import SwiftUI
import FlowStacks


struct SignContractView: View {
    @EnvironmentObject
    private var navigator: FlowNavigator<MainCoordinatorViewModel.Screen>
    @EnvironmentObject
    private var userInfo: UserInfo
    @State
    private var password: String = ""
    @FocusState
    private var isFocus: Bool
    @State
    private var currentPassword: String = ""
    
    var onSignSuccess: (() -> Void)?
    
    @Environment(\.partialSheetDismiss)
    var onDismiss
    
    var body: some View {
        
        VStack(spacing: 0) {
            Text("Sign the contract")
                .font(.titleH5)
                .foregroundStyle(.colorBaseTent)
                .frame(maxWidth: .infinity, alignment: .leading)
                .frame(height: 60)
            VStack(spacing: 4) {
                Text("Password")
                    .font(.labelSmallSecondary)
                    .foregroundStyle(.colorBaseTent)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.top, .lg)
                SecurePasswordTextField(placeHolder: "Enter your password", text: $password)
                    .focused($isFocus)
                    .frame(height: 44)
                    .overlay(
                        RoundedRectangle(cornerRadius: BorderRadius.full)
                            .stroke(isFocus ? .colorBorderPrimaryPressed : .colorBorderPrimaryDefault, lineWidth: isFocus ? 2 : 1)
                    )
            }
            .padding(.bottom, 40)
            
            HStack(spacing: .xl) {
                CustomButton(title: "Cancel", variant: .secondary) {
                    onDismiss?()
                }
                .frame(height: 56)
                let combinedBinding = Binding<Bool>(
                    get: { password == currentPassword && !currentPassword.isEmpty },
                    set: { _ in }
                )
                CustomButton(title: "Confirm", isEnable: combinedBinding) {
                    /*
                     guard let minWallet = userInfo.minWallet, !password.isBlank else { return }
                     let _ = signTx(wallet: minWallet, password: password, accountIndex: minWallet.accountIndex, txRaw: "")
                     */
                    onDismiss?()
                    onSignSuccess?()
                }
                .frame(height: 56)
            }
            .padding(.bottom, .md)
        }
        .padding(.horizontal, .xl)
        .task {
            guard currentPassword.isEmpty else { return }
            currentPassword = (try? AppSetting.getPasswordFromKeychain(username: AppSetting.USER_NAME)) ?? ""
        }
        .presentSheetModifier()
    }
}

#Preview {
    VStack {
        SignContractView()
        Spacer()
    }
}
