import SwiftUI
import FlowStacks


struct SearchTokenView: View {
    @EnvironmentObject
    private var navigator: FlowNavigator<MainCoordinatorViewModel.Screen>
    @FocusState
    private var isFocus: Bool
    @StateObject
    private var viewModel: SearchTokenViewModel = .init()

    var body: some View {
        VStack(spacing: 0) {
            HStack(alignment: .center, spacing: 0) {
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
                    if !viewModel.keyword.isBlank {
                        Image(.icCloseFill)
                            .fixSize(16)
                            .onTapGesture {
                                viewModel.keyword = ""
                            }
                            .padding(.horizontal, .md)
                    }
                }
                .padding(.md)
                .overlay(RoundedRectangle(cornerRadius: 20).stroke(.colorBorderPrimaryDefault, lineWidth: 1))
                Text("Cancel")
                    .padding(.horizontal, .xl)
                    .padding(.vertical, 6)
                    .contentShape(.rect)
                    .onTapGesture {
                        navigator.pop()
                    }
            }
            .padding(.leading, .xl)
            .padding(.top, .lg)
            if viewModel.showSkeleton {
                ScrollView {
                    VStack(alignment: .leading, spacing: 0) {
                        ForEach(0..<20, id: \.self) { index in
                            TokenListItemSkeletonView()
                        }
                    }
                    .padding(.top, .lg)
                }
            } else if viewModel.tokens.isEmpty && viewModel.tokensFav.isEmpty {
                VStack(alignment: .center, spacing: 16) {
                    Image(.icEmptyResult)
                        .fixSize(120)
                    Text("No results")
                        .font(.labelMediumSecondary)
                        .foregroundStyle(.colorBaseTent)
                }
                .padding(.top, 100)
                Spacer()
            } else {
                ScrollView {
                    VStack(
                        alignment: .leading, spacing: 0,
                        content: {
                            recentSearchView
                            favouriteView
                            tokensView
                            Spacer()
                        }
                    )
                }
                .padding(.top, .lg)
                Spacer(minLength: 0)
            }
        }
        /*
        .toolbar {
            ToolbarItemGroup(placement: .keyboard) {
                Spacer()
                Button("Done") {
                    self.isFocus = false
                }
                .foregroundStyle(.colorLabelToolbarDone)
            }
        }
         */
        .background(.colorBaseBackground)
        .onAppear {
            viewModel.getTokens()
        }
    }

    @ViewBuilder
    private var recentSearchView: some View {
        if !viewModel.recentSearch.isEmpty && viewModel.keyword.isBlank {
            VStack(alignment: .leading, spacing: .md) {
                HStack {
                    Text("Recent searches")
                        .font(.paragraphXSmall)
                        .foregroundStyle(.colorInteractiveTentPrimarySub)
                    Spacer()
                    Image(.icDelete)
                        .resizable()
                        .frame(width: .xl, height: .xl)
                        .onTapGesture {
                            viewModel.clearRecentSearch()
                        }
                }
                .frame(height: 32)
                .padding(.horizontal, .xl)
                HStack {
                    let recentSearch = viewModel.recentSearch.prefix(5)
                    ForEach(recentSearch, id: \.self) { token in
                        Text(token)
                            .font(.paragraphXMediumSmall)
                            .foregroundStyle(.colorBaseTent)
                            .padding(.horizontal, .md)
                            .frame(height: 40)
                            .background(RoundedRectangle(cornerRadius: 12).fill(.colorSurfacePrimaryDefault))
                            .onTapGesture {
                                viewModel.keyword = token
                            }
                    }
                }
                .padding(.horizontal, .xl)
            }
        }
    }

    @ViewBuilder
    private var favouriteView: some View {
        if !viewModel.tokensFav.isEmpty && viewModel.keyword.isBlank {
            Text("Favorites")
                .font(.paragraphXSmall)
                .foregroundStyle(.colorInteractiveTentPrimarySub)
                .frame(height: 32)
                .padding(.horizontal, .xl)
            ForEach(0..<viewModel.tokensFav.count, id: \.self) { index in
                if let item = viewModel.tokensFav[gk_safeIndex: index] {
                    let offsetBinding = Binding<CGFloat>(
                        get: {
                            viewModel.offsets[gk_safeIndex: index] ?? 0
                        },
                        set: { value in
                            guard index >= 0, index < viewModel.offsets.count else { return }
                            viewModel.offsets[index] = value
                        }
                    )
                    let deleteBinding = Binding<Bool>(
                        get: {
                            viewModel.isDeleted[gk_safeIndex: index] ?? false
                        },
                        set: { value in
                            guard index >= 0, index < viewModel.isDeleted.count else { return }
                            viewModel.isDeleted[index] = value
                        }
                    )

                    TokenListItemView(token: item, showBottomLine: index != viewModel.tokensFav.count - 1)
                        .contentShape(.rect)
                        .swipeToDelete(
                            offset: offsetBinding, isDeleted: deleteBinding, height: 68,
                            onDelete: {
                                viewModel.deleteTokenFav(at: index)
                            }
                        )
                        .zIndex(Double(index) * -1)
                        .onTapGesture {
                            navigator.push(.tokenDetail(token: item))
                        }
                }
            }
        }
    }

    @ViewBuilder
    private var tokensView: some View {
        if viewModel.keyword.isBlank {
            let spacing: CGFloat = {
                var spacing: CGFloat = 0
                if viewModel.tokensFav.isEmpty && viewModel.recentSearch.isEmpty {
                    spacing = 0
                } else if viewModel.tokensFav.isEmpty {
                    spacing = .md
                } else {
                    spacing = .md
                }
                return spacing
            }()
            Text("Top Vol 24h Tokens")
                .font(.paragraphXSmall)
                .foregroundStyle(.colorInteractiveTentPrimarySub)
                .frame(height: 32)
                .padding(.horizontal, .xl)
                .padding(.top, spacing)
        }
        ForEach(0..<viewModel.tokens.count, id: \.self) { index in
            if let item = viewModel.tokens[gk_safeIndex: index] {
                TokenListItemView(token: item)
                    .contentShape(.rect)
                    .onTapGesture {
                        viewModel.addRecentSearch(keyword: item.adaName)
                        navigator.push(.tokenDetail(token: item))
                    }
                    .onAppear() {
                        viewModel.loadMoreData(item: item)
                    }
            }
        }
    }
}

#Preview {
    SearchTokenView()
        .environmentObject(AppSetting.shared)
}
