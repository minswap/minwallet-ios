import SwiftUI
import FlowStacks


struct CreateNewWalletSuccessView: View {
    enum ScreenType {
        case newWallet
        case restoreWallet
    }

    @EnvironmentObject
    private var navigator: FlowNavigator<MainCoordinatorViewModel.Screen>
    @EnvironmentObject
    private var userInfo: UserInfo
    @EnvironmentObject
    private var appSetting: AppSetting
    @State
    var screenType: ScreenType = .newWallet

    var body: some View {
        VStack(alignment: .center, spacing: 0) {
            Image(.icToken)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 200)
                .padding(.top, 56)
            Text("You’re all set!")
                .font(.titleH4)
                .padding(.top, .xl)
                .foregroundStyle(.colorBaseTent)
            Text("You have successfully create a wallet. Minwallet makes exploring Cardano feel better than ever.")
                .font(.labelMediumSecondary)
                .lineSpacing(4)
                .foregroundStyle(.colorBaseTent)
                .multilineTextAlignment(.center)
                .padding(.top, .xl)
                .padding(.horizontal, 16.0)
            ZStack {
                HStack(alignment: .top) {
                    Image(.icTokenDark)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 172)
                        .padding(.top, 16.0)
                        .padding(.leading, -72)
                    Spacer()
                    Image(.icToken)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 120)
                        .padding(.top, -16.0)
                        .padding(.trailing, -50)
                }
            }
            Spacer()
            CustomButton(
                title: "Got it",
                variant: .primary,
                action: {
                    TokenManager.reset()
                    navigator.push(.home)
                }
            )
            .frame(height: 56)
            .padding(.horizontal, Spacing.xl)
            .safeAreaInset(edge: .bottom) {
                Color.clear.frame(height: 0)
            }
        }
        .background(.colorBaseBackground)
        .onAppear {
            appSetting.swipeEnabled = false
        }
    }
}

#Preview {
    CreateNewWalletSuccessView()
}
