import SwiftUI
import FlowStacks


struct TokenDetailView: View {
    @EnvironmentObject
    var navigator: FlowNavigator<MainCoordinatorViewModel.Screen>
    @EnvironmentObject
    var appSetting: AppSetting
    @EnvironmentObject
    var userInfo: UserInfo
    @Environment(\.colorScheme)
    var colorScheme: ColorScheme
    @StateObject
    var tokenManager: TokenManager = TokenManager.shared
    @StateObject
    var viewModel: TokenDetailViewModel = .init()
    @State
    var isShowToolTip: Bool = false
    @State
    var content: LocalizedStringKey = ""
    @State
    var title: LocalizedStringKey = ""
    @State
    var isCopiedTokenName: Bool = false
    @State
    var isCopiedPolicy: Bool = false
    
    var body: some View {
        ZStack {
            Color.colorBaseBackground.ignoresSafeArea()
            VStack(alignment: .leading, spacing: 0) {
                smallHeader
                    .padding(.top, .md)
                    .padding(.bottom, .md)
                OffsetObservingScrollView(offset: $viewModel.scrollOffset) {
                    VStack(spacing: 0) {
                        largeHeader.background {
                            GeometryReader { proxy in
                                Color.clear
                                    .onAppear {
                                        viewModel.sizeOfLargeHeader = proxy.size
                                    }
                            }
                        }
                        tokenDetailChartView
                            .padding(.top, .xl + .md)
                        tokenDetailStatisticView
                            .padding(.top, .xl)
                            .padding(.horizontal, .xl)
                    }
                }
                Spacer()
                Spacer()
                let tokenByID = tokenManager.tokenById(tokenID: viewModel.token.uniqueID)
                if let tokenByID = tokenByID, tokenByID.amount > 0 {
                    tokenDetailBottomView
                        .background(.colorBaseBackground)
                        .padding(.horizontal, .md)
                } else {
                    CustomButton(title: "Swap") {
                        navigator.push(.swapToken(.swapToken(token: viewModel.token)))
                    }
                    .frame(height: 56)
                    .padding(.horizontal, .xl)
                }
            }
            .presentSheet(isPresented: $isShowToolTip) {
                TokenDetailToolTipView(title: $title, content: $content)
                    .background(content: {
                        RoundedCorners(lineWidth: 0, tl: 24, tr: 24, bl: 0, br: 0)
                            .fill(.colorBaseBackground)
                            .ignoresSafeArea()
                        
                    })
            }
            .safeAreaInset(edge: .bottom) {
                Color.clear.frame(height: 0)
            }
            
        }
    }
}

#Preview {
    TokenDetailView(viewModel: TokenDetailViewModel(token: TokenProtocolDefault()))
        .environmentObject(AppSetting.shared)
}
