import SwiftUI
import FlowStacks


struct OrderHistoryView: View {
    @EnvironmentObject
    var navigator: FlowNavigator<MainCoordinatorViewModel.Screen>
    @EnvironmentObject
    var hud: HUDState
    @EnvironmentObject
    var appSetting: AppSetting
    @EnvironmentObject
    var bannerState: BannerState
    @StateObject
    var viewModel: OrderHistoryViewModel = .init()
    @FocusState
    var isFocus: Bool
    @State
    var scrollOffset: CGPoint = .zero
    @State
    private var isShowSignContract: Bool = false
    @StateObject
    var filterViewModel: OrderHistoryFilterViewModel = .init()
    
    //TODO: Remove
    @State
    private var showInputFakeAddress = false
    @State
    private var fakeWalletAddress: String = AppSetting.shared.fakeWalletAddress
    
    var body: some View {
        ZStack {
            Color.colorBaseBackground.ignoresSafeArea()
            VStack(alignment: .leading, spacing: 0) {
                headerView
                    .padding(.top, .md)
                    //TODO: Remove
                    .onLongPressGesture {
                        guard AppSetting.fakeWalletAddress else { return }
                        showInputFakeAddress = true
                    }
                OffsetObservingScrollView(
                    offset: $scrollOffset,
                    onRefreshable: {
                        await viewModel.fetchData(fromPullToRefresh: true)
                    },
                    content: {
                        contentView
                    })
                if !viewModel.showSearch && viewModel.wrapOrders.isEmpty && !viewModel.showSkeleton {
                    CustomButton(title: "Swap") {
                        navigator.push(.swapToken(.swapToken(token: nil)))
                    }
                    .frame(height: 56)
                    .padding(.horizontal, .xl)
                    .transition(.opacity)
                }
            }
            .safeAreaInset(edge: .bottom) {
                Color.clear.frame(height: 0)
            }
        }
        .presentSheet(isPresented: $viewModel.showFilterView) {
            OrderHistoryFilterView(
                viewModel: filterViewModel,
                onFilterSelected: { filterSource, status, source, action, fromDate, toDate in
                    Task {
                        viewModel.filterSourceSelected = filterSource
                        viewModel.statusSelected = status
                        viewModel.orderType = action
                        viewModel.source = source
                        viewModel.fromDate = fromDate
                        viewModel.toDate = toDate
                        await viewModel.fetchData()
                    }
                }
            )
        }
        .presentSheet(isPresented: $isShowSignContract) {
            SignContractView(
                onSignSuccess: {
                    authenticationSuccess()
                }
            )
        }
        .presentSheet(
            isPresented: $viewModel.showCancelOrderList,
            onDimiss: {
                viewModel.orderCancelSelected = [:]
                viewModel.orderCancelCanSelect = [:]
            },
            content: {
                OrderHistoryCancelView(
                    orders: .constant(viewModel.orderCancel?.orders.filter({ $0.status == .created }) ?? []),
                    orderSelected: $viewModel.orderCancelSelected,
                    orderCanSelect: $viewModel.orderCancelCanSelect,
                    onCancelOrder: {
                        $viewModel.showCancelOrder.showSheet()
                    })
            }
        )
        .presentSheet(isPresented: $viewModel.showCancelOrder) {
            OrderHistoryConfirmCancelView {
                Task {
                    do {
                        switch appSetting.authenticationType {
                        case .biometric:
                            try await appSetting.reAuthenticateUser()
                            authenticationSuccess()
                        case .password:
                            $isShowSignContract.showSheet()
                        }
                    } catch {
                        bannerState.showBannerError(error.localizedDescription)
                    }
                }
            }
        }
        //TODO: Remove
        .alert("Address wallet", isPresented: $showInputFakeAddress) {
            TextField("Address", text: $fakeWalletAddress)
            Button("OK") {
                Task {
                    AppSetting.shared.fakeWalletAddress = fakeWalletAddress
                    await viewModel.fetchData(fromPullToRefresh: true)
                }
            }
            Button("Cancel", role: .cancel) {
                
            }
        } message: {
            Text("Please enter wallet address below. Empty will use your current wallet address.")
        }
    }
    
    private func authenticationSuccess() {
        Task {
            do {
                hud.showLoading(true)
                let finalID = try await viewModel.cancelOrder()
                hud.showLoading(false)
                bannerState.infoContent = {
                    bannerState.infoContentDefault(onViewTransaction: {
                        finalID?.viewTransaction()
                    })
                }
                bannerState.showBanner(isShow: true)
            } catch {
                hud.showLoading(false)
                bannerState.showBannerError(error.rawError)
            }
        }
    }
}

#Preview {
    OrderHistoryView()
}
