import SwiftUI
import FlowStacks


struct AboutView: View {
    @EnvironmentObject
    var navigator: FlowNavigator<MainCoordinatorViewModel.Screen>

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("About Minwallet")
                .font(.titleH5)
                .frame(maxWidth: .infinity, alignment: .leading)
                .frame(height: 60)
                .padding(.horizontal, .xl)
            Text("About")
                .font(.paragraphXMediumSmall)
                .foregroundStyle(.colorInteractiveTentPrimarySub)
                .padding(.horizontal, .xl)
                .padding(.top, .xl)
            HStack(spacing: 12) {
                Text("Privacy policy")
                    .font(.labelSmallSecondary)
                    .foregroundStyle(.colorBaseTent)
                Spacer()
                Image(.icNext)
                    .frame(width: 20, height: 20)
            }
            .frame(height: 52)
            .padding(.horizontal, .xl)
            .contentShape(.rect)
            .onTapGesture {
                navigator.push(.policy(.about))
            }
            HStack(spacing: 12) {
                Text("Terms of service")
                    .font(.labelSmallSecondary)
                    .foregroundStyle(.colorBaseTent)
                Spacer()
                Image(.icNext)
                    .frame(width: 20, height: 20)
            }
            .frame(height: 52)
            .padding(.horizontal, .xl)
            .contentShape(.rect)
            .onTapGesture {
                navigator.push(.termOfService)
            }
            /*
            Color.colorBorderPrimarySub.frame(height: 1)
                .padding(.horizontal, .xl)
                .padding(.vertical, .xl)
            Text("About")
                .font(.paragraphXMediumSmall)
                .foregroundStyle(.colorInteractiveTentPrimarySub)
                .padding(.horizontal, .xl)
            HStack(spacing: 12) {
                Text("Get help")
                    .font(.labelSmallSecondary)
                    .foregroundStyle(.colorBaseTent)
                Spacer()
                Image(.icNext)
                    .frame(width: 20, height: 20)
            }
            .frame(height: 52)
            .padding(.horizontal, .xl)
            HStack(spacing: 12) {
                Text("Share feedback")
                    .font(.labelSmallSecondary)
                    .foregroundStyle(.colorBaseTent)
                Spacer()
                Image(.icNext)
                    .frame(width: 20, height: 20)
            }
            .frame(height: 52)
            .padding(.horizontal, .xl)
             */
            Spacer()
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
    AboutView()
}
