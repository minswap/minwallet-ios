import SwiftUI
import FlowStacks


struct ForgotPasswordView: View {
    enum ScreenType {
        case enterPassword
        case changeYourPassword(ChangePasswordView.ScreenType)
    }

    @EnvironmentObject
    private var navigator: FlowNavigator<MainCoordinatorViewModel.Screen>
    @EnvironmentObject
    private var appSetting: AppSetting
    @EnvironmentObject
    private var userInfo: UserInfo
    @State
    private var conditionOne: Bool = false
    @State
    private var conditionTwo: Bool = false
    @State
    var screenType: ScreenType

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("Forgot password")
                .font(.titleH5)
                .foregroundStyle(.colorBaseTent)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.top, .lg)
                .padding(.bottom, .xl)
                .padding(.horizontal, .xl)

            VStack(alignment: .leading, spacing: .xl) {
                HStack(spacing: .xl) {
                    Image(conditionOne ? .icChecked : .icUnchecked).resizable().frame(width: 20, height: 20)
                    Text("The seed phrase is only stored on your phone, and Minswap has no access to it to help you retrieve it")
                        .font(.paragraphSmall)
                        .foregroundStyle(.colorInteractiveTentPrimarySub)
                }
                .padding(.horizontal, .xl)
                .contentShape(.rect)
                .onTapGesture {
                    conditionOne.toggle()
                }
                Color.colorBorderPrimaryTer.frame(height: 1)
                    .padding(.trailing, .xl)
                    .padding(.leading, 54)
                HStack(spacing: .xl) {
                    Image(conditionTwo ? .icChecked : .icUnchecked).resizable().frame(width: 20, height: 20)
                    Text("If you forget your password, you can reset it by restoring your wallet. You can import your wallet again using the seed phrase or JSON file, and your assets will not be impacted.")
                        .font(.paragraphSmall)
                        .foregroundStyle(.colorInteractiveTentPrimarySub)
                }
                .padding(.horizontal, .xl)
                .contentShape(.rect)
                .onTapGesture {
                    conditionTwo.toggle()
                }
            }
            .padding(.top, .lg)
            Spacer()
            let combinedBinding = Binding<Bool>(
                get: { conditionOne && conditionTwo },
                set: { newValue in
                    conditionOne = newValue
                    conditionTwo = newValue
                }
            )

            CustomButton(title: "Restore", isEnable: combinedBinding) {
                userInfo.deleteAccount()
                appSetting.deleteAccount()
                if appSetting.rootScreen != .gettingStarted {
                    appSetting.rootScreen = .gettingStarted
                }
                navigator.popToRoot()
            }
            .frame(height: 56)
            .padding(.horizontal, .xl)
            .disabled(!conditionOne || !conditionTwo)
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
    ForgotPasswordView(screenType: .enterPassword)
}
