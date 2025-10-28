import SwiftUI
import FlowStacks

struct GettingStartedView: View {

    @EnvironmentObject
    private var navigator: FlowNavigator<MainCoordinatorViewModel.Screen>

    @EnvironmentObject
    private var appSetting: AppSetting

    var body: some View {
        VStack(spacing: 0) {
            Image(.icToken)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 200)
                .padding(.top, 56)
            Text("Getting started now")
                .font(.titleH4)
                .padding(.top, .xl)
                .foregroundStyle(.colorBaseTent)
            Text("Minwallet is a secure and user-friendly wallet built directly into Minswap for seamless token swapping and management.")
                .lineSpacing(4)
                .font(.labelMediumSecondary)
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
                title: "Create new wallet",
                action: {
                    navigator.push(.createWallet(.createWallet))
                }
            )
            .frame(height: 56)
            .padding(.horizontal, Spacing.xl)
            CustomButton(
                title: "Restore wallet",
                variant: .secondary,
                action: {
                    navigator.push(.restoreWallet(.restoreWallet))
                }
            )
            .frame(height: 56)
            .padding(.top, 16)
            .padding(.horizontal, Spacing.xl)
        }
        .safeAreaInset(edge: .bottom) {
            Color.clear.frame(height: 0)  // Adds 20 points of spacing at the bottom
        }
        .background(Color.colorBaseBackground)
        .onAppear {
            appSetting.isFirstTimeRunApp = false
        }
    }
}

#Preview {
    GettingStartedView()
        .environmentObject(AppSetting.shared)
}
