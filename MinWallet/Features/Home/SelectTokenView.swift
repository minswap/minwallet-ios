import SwiftUI
import FlowStacks


struct SelectTokenView: View {
    enum ScreenType {
        case initSelectedToken
        case sendToken
        case swapToken
    }
    
    @EnvironmentObject
    private var navigator: FlowNavigator<MainCoordinatorViewModel.Screen>
    @FocusState
    private var isFocus: Bool
    @Environment(\.partialSheetDismiss)
    private var onDismiss
    
    init(
        viewModel: SelectTokenViewModel,
        onSelectToken: (([TokenProtocol], Bool) -> Void)?
    ) {
        self._viewModel = .init(wrappedValue: viewModel)
        self.onSelectToken = onSelectToken
    }
    
    @StateObject
    private var viewModel: SelectTokenViewModel
    
    var onSelectToken: (([TokenProtocol], Bool) -> Void)?
    
    var body: some View {
        ZStack {
            Color.colorBaseBackground.ignoresSafeArea()
            VStack(
                spacing: 0,
                content: {
                    if viewModel.screenType == .initSelectedToken {
                        headerView
                    }
                    contentView
                    if viewModel.screenType == .initSelectedToken || viewModel.screenType == .sendToken {
                        let combinedBinding = Binding<Bool>(
                            get: { viewModel.tokensSelected.count > 0 },
                            set: { _ in }
                        )
                        CustomButton(
                            title: viewModel.screenType == .initSelectedToken ? "Next" : "Confirm",
                            isEnable: combinedBinding
                        ) {
                            let tokenSelected = viewModel.tokenCallBack
                            switch viewModel.screenType {
                            case .initSelectedToken:
                                guard !tokenSelected.isEmpty else { return }
                                onSelectToken?(tokenSelected, false)
                                navigator.push(.sendToken(.sendToken(tokensSelected: tokenSelected, sendAll: false, screenType: viewModel.sourceScreenType)))
                            case .sendToken:
                                onSelectToken?(tokenSelected, false)
                                onDismiss?()
                            case .swapToken:
                                break
                            }
                        }
                        .frame(height: 56)
                        .padding(.horizontal, .xl)
                        .safeAreaInset(edge: .bottom) {
                            Color.clear.frame(height: 0)
                        }
                    }
                }
            )
            .ignoresSafeArea(.keyboard)
        }
        .background(.colorBaseBackground)
    }
    
    @ViewBuilder
    private var headerView: some View {
        HStack(spacing: .lg) {
            Button(
                action: {
                    navigator.pop()
                },
                label: {
                    Image(.icBack)
                        .resizable()
                        .frame(width: ._3xl, height: ._3xl)
                        .padding(.md)
                        .background(RoundedRectangle(cornerRadius: BorderRadius.full).stroke(.colorBorderPrimaryTer, lineWidth: 1))
                }
            )
            .buttonStyle(.plain)
            Spacer()
            HStack(spacing: 8) {
                Text("Send all")
                    .font(.labelMediumSecondary)
                    .foregroundStyle(.colorInteractiveTentSecondaryDefault)
                Image(.icSendAll)
                    .fixSize(20)
            }
            .padding(.horizontal, .xl)
            .frame(height: 40)
            .background(
                RoundedRectangle(cornerRadius: BorderRadius.full).fill(.colorSurfacePrimaryDefault)
            )
            .contentShape(.rect)
            .onTapGesture {
                onSelectToken?(viewModel.rawTokens, true)
                navigator.push(.sendToken(.sendToken(tokensSelected: viewModel.rawTokens, sendAll: true, screenType: viewModel.sourceScreenType)))
            }
        }
        .frame(height: 48)
        .padding(.horizontal, .xl)
        Text("You want to send")
            .font(.titleH5)
            .frame(maxWidth: .infinity, alignment: .leading)
            .frame(height: 60)
            .padding(.horizontal, .xl)
    }
    
    private var contentView: some View {
        VStack(spacing: .md) {
            HStack(spacing: .md) {
                Image(.icSearch)
                    .resizable()
                    .frame(width: 20, height: 20)
                TextField("", text: $viewModel.keyword)
                    .placeholder("Search", when: viewModel.keyword.isEmpty)
                    .focused($isFocus)
                    .lineLimit(1)
                    .keyboardType(.asciiCapable)
                    .submitLabel(.done)
                    .autocorrectionDisabled()
            }
            .padding(.md)
            .overlay(RoundedRectangle(cornerRadius: 20).stroke(.colorBorderPrimaryDefault, lineWidth: 1))
            .padding(.horizontal, .xl)
            .padding(.top, .lg)
            ScrollViewReader { value in
                ScrollView {
                    if viewModel.showSkeleton {
                        LazyVStack(
                            spacing: 0,
                            content: {
                                ForEach(0..<20, id: \.self) { index in
                                    TokenListItemSkeletonView()
                                }
                            }
                        )
                        .padding(.top, .xl)
                    } else if viewModel.tokens.isEmpty {
                        VStack(alignment: .center, spacing: 16) {
                            Image(.icEmptyResult)
                                .fixSize(120)
                            Text("No results")
                                .font(.labelMediumSecondary)
                                .foregroundStyle(.colorBaseTent)
                        }
                        .padding(.top, 50)
                    } else {
                        LazyVStack(
                            spacing: 0,
                            content: {
                                Color.clear.frame(height: 0.1)
                                    .id(0)
                                ForEach($viewModel.tokens) { $item in
                                    let item = $item.wrappedValue.token
                                    if viewModel.screenType == .initSelectedToken || viewModel.screenType == .sendToken {
                                        let combinedBinding = Binding<Bool>(
                                            get: { viewModel.tokensSelected[item.uniqueID] != nil },
                                            set: { _ in }
                                        )
                                        SelectTokenListItemView(
                                            token: item,
                                            isSelected: combinedBinding,
                                            isShowSelected: true,
                                            isFav: UserInfo.shared.tokensFav.contains(where: { $0.uniqueID == item.uniqueID })
                                        )
                                        .contentShape(.rect)
                                        .onTapGesture {
                                            viewModel.toggleSelected(token: item)
                                        }
                                    } else {
                                        let combinedBinding = Binding<Bool>(
                                            get: { viewModel.tokensSelected[item.uniqueID] != nil },
                                            set: { _ in }
                                        )
                                        SelectTokenListItemView(
                                            token: item,
                                            isSelected: combinedBinding,
                                            isShowSelected: false,
                                            isFav: UserInfo.shared.tokensFav.contains(where: { $0.uniqueID == item.uniqueID })
                                        )
                                        .contentShape(.rect)
                                        .onAppear() {
                                            viewModel.loadMoreData(item: item)
                                        }
                                        .onTapGesture {
                                            viewModel.toggleSelected(token: item)
                                            onDismiss?()
                                            let tokenSelected = viewModel.tokenCallBack
                                            onSelectToken?(tokenSelected, false)
                                        }
                                    }
                                }
                            }
                        )
                        .onChange(of: viewModel.scrollToTop) { scrollToTop in
                            guard scrollToTop else { return }
                            DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(200)) {
                                value.scrollTo(0, anchor: .top)
                            }
                        }
                    }
                }
            }
            .refreshable {
                switch viewModel.screenType {
                case .swapToken:
                    viewModel.getTokens()
                default:
                    break
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

#Preview {
    SelectTokenView(
        viewModel: SelectTokenViewModel(tokensSelected: [TokenProtocolDefault()], screenType: .initSelectedToken, sourceScreenType: .normal),
        onSelectToken: { _, _ in
        }
    )
    .environmentObject(AppSetting.shared)
}
