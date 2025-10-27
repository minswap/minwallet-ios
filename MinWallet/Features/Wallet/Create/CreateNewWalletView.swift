import SwiftUI
import FlowStacks


struct CreateNewWalletView: View {
    @EnvironmentObject
    var navigator: FlowNavigator<MainCoordinatorViewModel.Screen>
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("Create new wallet")
                .font(.titleH5)
                .foregroundStyle(.colorBaseTent)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.top, .lg)
                .padding(.bottom, .xl)
                .padding(.horizontal, .xl)
            Text("Before you start, please read and keep the following security tips in mind.")
                .font(.paragraphSmall)
                .foregroundStyle(.colorBaseTent)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, .xl)
                .padding(.top, .lg)
                .padding(.bottom, ._3xl)
            HStack(spacing: .xl) {
                Image(.icChecked)
                Text("If I lose my seed phrase, my assets will be lost forever.")
                    .font(.paragraphSmall)
                    .foregroundStyle(.colorInteractiveTentPrimarySub)
            }
            .padding(.horizontal, .xl)
            Color.colorBorderPrimaryTer.frame(height: 1)
                .padding(.leading, 52)
                .padding(.trailing, .xl)
                .padding(.vertical, .xl)
            HStack(spacing: .xl) {
                Image(.icChecked)
                Text("If I share my seed phrase with others, my assets will be stolen.")
                    .font(.paragraphSmall)
                    .foregroundStyle(.colorInteractiveTentPrimarySub)
            }
            .padding(.horizontal, .xl)
            Color.colorBorderPrimaryTer.frame(height: 1)
                .padding(.leading, 52)
                .padding(.trailing, .xl)
                .padding(.vertical, .xl)
            HStack(spacing: .xl) {
                Image(.icChecked)
                Text("The seed phrase is only stored on my phone, and Minswap has no access to it.")
                    .font(.paragraphSmall)
                    .foregroundStyle(.colorInteractiveTentPrimarySub)
            }
            .padding(.horizontal, .xl)
            Color.colorBorderPrimaryTer.frame(height: 1)
                .padding(.leading, 52)
                .padding(.trailing, .xl)
                .padding(.vertical, .xl)
            HStack(spacing: .xl) {
                Image(.icChecked)
                Text("If I clear my local storage without backing up the seed phrase, Minswap cannot retrieve it for me.")
                    .font(.paragraphSmall)
                    .foregroundStyle(.colorInteractiveTentPrimarySub)
            }
            .padding(.horizontal, .xl)
            Spacer()
            CustomButton(title: "Next") {
                navigator.push(.createWallet(.seedPhrase))
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
    CreateNewWalletView()
}
