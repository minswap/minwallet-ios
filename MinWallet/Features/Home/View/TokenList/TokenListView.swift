import SwiftUI
import FlowStacks
import SkeletonUI


struct TokenListView: View {
    @EnvironmentObject
    private var navigator: FlowNavigator<MainCoordinatorViewModel.Screen>
    @EnvironmentObject
    private var tokenManager: TokenManager
    
    @ObservedObject
    var viewModel: HomeViewModel
    
    private let columns = [
        GridItem(.flexible(), spacing: .xl),
        GridItem(.flexible(), spacing: .xl),
    ]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            if tokenManager.hasTokenOrNFT && !viewModel.showSkeleton {
                HStack(spacing: 0) {
                    ScrollView(.horizontal) {
                        HStack(spacing: 0) {
                            ForEach(viewModel.tabTypes) { type in
                                Text(type.title)
                                    .font(.labelSmallSecondary)
                                    .foregroundStyle(viewModel.tabType == type ? .colorInteractiveTentSecondaryDefault : .colorInteractiveTentPrimarySub)
                                    .frame(height: 28)
                                    .padding(.horizontal, .lg)
                                    .background(viewModel.tabType == type ? .colorSurfacePrimaryDefault : .clear)
                                    .cornerRadius(BorderRadius.full)
                                    .padding(.trailing, .lg)
                                    .layoutPriority(viewModel.tabType == type ? 998 : viewModel.tabType.layoutPriority)
                                    .onTapGesture {
                                        viewModel.showSkeleton(tabType: type)
                                        withAnimation {
                                            viewModel.tabType = type
                                        }
                                    }
                            }
                        }
                    }
                    .scrollIndicators(.hidden)
                    if let countToken = viewModel.countToken, countToken > 0 {
                        let suffix = viewModel.tabType == .yourToken ? "tokens" : "NFTs"
                        Spacer()
                        Color.colorBorderPrimarySub.frame(width: 1, height: 20)
                        Text("\(countToken) \(suffix)")
                            .font(.paragraphSmall)
                            .foregroundStyle(.colorInteractiveTentPrimarySub)
                            .padding(.leading, .md)
                            .layoutPriority(999)
                    }
                }
                .frame(height: 36)
                .padding(.horizontal, .xl)
                .padding(.bottom, .lg)
            } else if !tokenManager.hasTokenOrNFT && !viewModel.showSkeleton {
                Text("Crypto prices")
                    .padding(.horizontal, .xl)
                    .font(.titleH6)
                    .foregroundStyle(.colorBaseTent)
                    .padding(.bottom, .lg)
            }
            if viewModel.showSkeleton {
                ScrollView {
                    ForEach(0..<20, id: \.self) { index in
                        TokenListItemSkeletonView()
                    }
                }
                .scrollDisabled(true)
            } else {
                if viewModel.tabType == .market {
                    marketView.tag(TokenListView.TabType.market)
                } else if viewModel.tabType == .yourToken {
                    yourTokenView.tag(TokenListView.TabType.yourToken)
                } else if viewModel.tabTypes.contains(.nft) {
                    nftView.tag(TokenListView.TabType.nft)
                }
            }
        }
        .onAppear {
            viewModel.favTokenIds = UserInfo.shared.tokensFav.map({ $0.uniqueID })
        }
    }
}

#Preview {
    HomeView()
        .environmentObject(AppSetting.shared)
        .environmentObject(UserInfo.shared)
}


extension TokenListView {
    static let marketUUID = UUID()
    static let yourTokenUUID = UUID()
    static let nftUUID = UUID()
    
    enum TabType: Int, CaseIterable, Identifiable {
        var id: UUID {
            switch self {
            case .market:
                return marketUUID
            case .yourToken:
                return yourTokenUUID
            case .nft:
                return nftUUID
            }
        }
        
        case market = 0
        case yourToken = 1
        case nft = 2
        
        var title: LocalizedStringKey {
            switch self {
            case .market:
                "Market"
            case .yourToken:
                "Your tokens"
            case .nft:
                "Your NFTs"
            }
        }
        
        var layoutPriority: Double {
            switch self {
            case .market:
                return 9
            case .yourToken:
                return 8
            case .nft:
                return 7
            }
        }
    }
}


extension TokenListView {
    @ViewBuilder
    var marketView: some View {
        if viewModel.marketViewModel.showSkeleton ?? true {
            ForEach(0..<20, id: \.self) { index in
                TokenListItemSkeletonView()
            }
        } else if viewModel.marketViewModel.tokens.isEmpty {
            HStack {
                Spacer(minLength: 0)
                VStack(alignment: .center, spacing: 16) {
                    Image(.icEmptyResult)
                        .fixSize(120)
                    Text("No results")
                        .font(.labelMediumSecondary)
                        .foregroundStyle(.colorBaseTent)
                }
                Spacer(minLength: 0)
            }
            .padding(.top, 50)
        } else {
            LazyVStack(
                spacing: 0,
                content: {
                    let tokens: [TokenProtocol] = viewModel.marketViewModel.tokens
                    ForEach(0..<tokens.count, id: \.self) { index in
                        if let item = tokens[gk_safeIndex: index] {
                            TokenListItemView(token: item, showSubPrice: false, isFav: viewModel.favTokenIds.contains(where: { $0 == item.uniqueID }))
                                .contentShape(.rect)
                                .onAppear() {
                                    viewModel.marketViewModel.loadMoreData(item: item)
                                }
                                .onTapGesture {
                                    guard !item.isTokenADA else { return }
                                    navigator.push(.tokenDetail(token: item))
                                }
                        }
                    }
                })
        }
    }
    
    @ViewBuilder
    var yourTokenView: some View {
        if (viewModel.yourTokenViewModel.showSkeleton ?? true) {
            ForEach(0..<20, id: \.self) { index in
                TokenListItemSkeletonView()
            }
        } else if viewModel.yourTokenViewModel.tokens.isEmpty {
            HStack {
                Spacer(minLength: 0)
                VStack(alignment: .center, spacing: 16) {
                    Image(.icEmptyResult)
                        .fixSize(120)
                    Text("No results")
                        .font(.labelMediumSecondary)
                        .foregroundStyle(.colorBaseTent)
                }
                Spacer(minLength: 0)
            }
            .padding(.top, 50)
        } else {
            LazyVStack(
                spacing: 0,
                content: {
                    let tokens: [TokenProtocol] = viewModel.yourTokenViewModel.tokens
                    ForEach(0..<tokens.count, id: \.self) { index in
                        if let item = tokens[gk_safeIndex: index] {
                            TokenListItemView(token: item, showSubPrice: true, isFav: viewModel.favTokenIds.contains(where: { $0 == item.uniqueID }))
                                .contentShape(.rect)
                                .onTapGesture {
                                    guard !item.isTokenADA else { return }
                                    navigator.push(.tokenDetail(token: item))
                                }
                        }
                    }
                })
        }
    }
    
    @ViewBuilder
    var nftView: some View {
        if (viewModel.nftViewModel.showSkeleton ?? true) {
            ForEach(0..<20, id: \.self) { index in
                TokenListItemSkeletonView()
            }
        } else if viewModel.nftViewModel.tokens.isEmpty {
            HStack {
                Spacer(minLength: 0)
                VStack(alignment: .center, spacing: 16) {
                    Image(.icEmptyResult)
                        .fixSize(120)
                    Text("No results")
                        .font(.labelMediumSecondary)
                        .foregroundStyle(.colorBaseTent)
                }
                Spacer(minLength: 0)
            }
            .padding(.top, 50)
        } else {
            LazyVGrid(columns: columns, spacing: .xl) {
                let tokens: [TokenProtocol] = viewModel.nftViewModel.tokens
                ForEach(0..<tokens.count, id: \.self) { index in
                    if let item = tokens[gk_safeIndex: index] {
                        VStack(alignment: .leading, spacing: .md) {
                            if item.isAdaHandleName {
                                ZStack(alignment: .center) {
                                    Image(.icNftAdaHandle)
                                        .resizable()
                                        .aspectRatio(1, contentMode: .fit)
                                        .frame(maxWidth: .infinity)
                                        .cornerRadius(.xl)
                                    Text(item.tokenName.adaName)
                                        .font(.labelMediumSecondary)
                                        .foregroundStyle(.white)
                                }
                            } else {
                                CustomWebImage(
                                    url: item.buildNFTURL(),
                                    placeholder: {
                                        Image(nil)
                                            .resizable()
                                            .scaledToFill()
                                            .background(.colorSurfacePrimaryDefault)
                                            .clipped()
                                            .overlay {
                                                Image(.icNftPlaceholder)
                                                    .fixSize(44)
                                            }
                                    }
                                )
                                .cornerRadius(.xl)
                            }
                            
                            let name = item.isAdaHandleName ? "$\(item.tokenName.adaName ?? "")" : (item.nftDisplayName.isBlank ? item.adaName : item.nftDisplayName)
                            Text(name)
                                .lineLimit(1)
                                .font(.paragraphXMediumSmall)
                                .foregroundStyle(.colorBaseTent)
                        }
                    }
                }
            }
            .padding(.horizontal, 16)
        }
    }
}
