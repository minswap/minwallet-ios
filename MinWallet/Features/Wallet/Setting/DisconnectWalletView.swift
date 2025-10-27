import SwiftUI
import FlowStacks


struct DisconnectWalletView: View {
    @EnvironmentObject
    private var navigator: FlowNavigator<MainCoordinatorViewModel.Screen>
    @EnvironmentObject
    private var userInfo: UserInfo
    @EnvironmentObject
    private var appSetting: AppSetting
    @State
    private var conditionOne: Bool = false
    @State
    private var conditionTwo: Bool = false
    @Environment(\.partialSheetDismiss)
    var onDismiss
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("Disconnect wallet")
                .font(.titleH5)
                .frame(maxWidth: .infinity, alignment: .leading)
                .frame(height: 60)
            Image(.icDisconnectWallet)
                .resizable()
                .frame(width: 124, height: 124)
                .padding(.top, .lg)
                .padding(.bottom, .xl)
            Text("You are disconnecting your wallet?")
                .font(.labelMediumSecondary)
            HStack(alignment: .center, spacing: .md) {
                Image(conditionOne ? .icChecked : .icRadioUncheck)
                    .resizable()
                    .frame(width: 20, height: 20)
                Text("You have to re-enter your seed phrases when reconnecting your wallet.")
                    .font(.paragraphSmall)
                    .foregroundStyle(.colorInteractiveTentPrimarySub)
            }
            .padding(.top, .xl)
            .contentShape(.rect)
            .onTapGesture {
                conditionOne.toggle()
            }
            Color.colorBorderPrimaryTer.frame(height: 1)
                .padding(.leading, 28)
                .padding(.vertical, .xl)
            HStack(alignment: .center, spacing: .md) {
                Image(conditionTwo ? .icChecked : .icRadioUncheck)
                    .resizable()
                    .frame(width: 20, height: 20)
                Text("In case you forgot your seed phrase, Minswap can not retrieve your wallet once you click Disconnect button.")
                    .font(.paragraphSmall)
                    .foregroundStyle(.colorInteractiveTentPrimarySub)
            }
            .contentShape(.rect)
            .onTapGesture {
                conditionTwo.toggle()
            }
            
            let combinedBinding = Binding<Bool>(
                get: { conditionOne && conditionTwo },
                set: { newValue in
                    conditionOne = newValue
                    conditionTwo = newValue
                }
            )
            HStack(spacing: .xl) {
                CustomButton(title: "Cancel", variant: .secondary) {
                    onDismiss?()
                }
                .frame(height: 56)
                CustomButton(
                    title: "Disconnect",
                    variant: .other(
                        textColor: .colorBaseTent,
                        backgroundColor: .colorInteractiveDangerDefault,
                        borderColor: .clear,
                        textColorDisable: .colorSurfaceDangerPressed,
                        backgroundColorDisable: .colorSurfaceDanger
                    ),
                    isEnable: combinedBinding
                ) {
                    appSetting.deleteAccount()
                    userInfo.deleteAccount()
                    onDismiss?()
                    if appSetting.rootScreen != .gettingStarted {
                        appSetting.rootScreen = .gettingStarted
                    }
                    navigator.popToRoot()
                }
                .frame(height: 56)
                .disabled(!conditionOne || !conditionTwo)
            }
            .padding(.top, 40)
            .padding(.bottom, .md)
        }
        .padding(.horizontal, .xl)
        .presentSheetModifier()
    }
}

#Preview {
    VStack {
        DisconnectWalletView()
        Spacer()
    }
}
