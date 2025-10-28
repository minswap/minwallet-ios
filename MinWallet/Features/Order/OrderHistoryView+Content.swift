import SwiftUI
import FlowStacks


extension OrderHistoryView {
    static let heightOrder: CGFloat = 60

    var contentView: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("")
                .frame(maxWidth: .infinity, maxHeight: viewModel.showSearch ? 12 : 0.01, alignment: .leading)
            if !viewModel.showSearch {
                Text("Orders")
                    .foregroundStyle(.colorBaseTent)
                    .font(.titleH4)
                    .frame(maxWidth: .infinity, minHeight: Self.heightOrder, maxHeight: Self.heightOrder, alignment: .leading)
                    .padding(.horizontal)
            }
            if viewModel.showSkeleton {
                ForEach(0..<20, id: \.self) { index in
                    TokenListItemSkeletonView(showLogo: false)
                }
            } else if viewModel.showSearch && viewModel.wrapOrders.isEmpty {
                HStack {
                    Spacer()
                    emptySearch
                    Spacer()
                }
                .frame(maxWidth: .infinity)
                .padding(.top, 120)
                .transition(.opacity)
            } else if !viewModel.showSearch && viewModel.wrapOrders.isEmpty {
                HStack {
                    Spacer()
                    emptyOrders
                    Spacer()
                }
                .frame(maxWidth: .infinity)
                .padding(.top, 56)
                .transition(.opacity)
            } else {
                LazyVStack(spacing: 0) {
                    ForEach(Array(viewModel.wrapOrders.enumerated()), id: \.offset) { index, order in
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

                        let onCancelItem: () -> Void = {
                            viewModel.orderCancel = order
                            if viewModel.hasOnlyOneOrderCancel {
                                $viewModel.showCancelOrder.showSheet()
                            } else {
                                $viewModel.showCancelOrderList.showSheet()
                            }
                            viewModel.offsets[index] = 0
                        }

                        let onAppear: () -> Void = {
                            viewModel.loadMoreData(order: order)
                        }

                        let onTapGesture: () -> Void = {
                            navigator.push(
                                .orderHistoryDetail(
                                    wrapOrder: order,
                                    onReloadOrder: {
                                        Task {
                                            await viewModel.fetchData(showSkeleton: false)
                                        }
                                    }))
                        }
                        OrderHistoryItemView(
                            wrapOrder: order,
                            onCancelItem: onCancelItem
                        )
                        .padding(.horizontal, .xl)
                        .contentShape(.rect)
                        .swipeToDelete(
                            offset: offsetBinding,
                            isDeleted: deleteBinding,
                            enableDrag: .constant(order.status == .created),
                            height: .constant(order.heightSize),
                            image: .icCancelOrder,
                            onDelete: onCancelItem
                        )
                        .zIndex(Double(index) * -1)
                        .onAppear(perform: onAppear)
                        .onTapGesture {
                            onTapGesture()
                        }
                    }
                }
            }
            Spacer()
        }
    }

    var emptyOrders: some View {
        VStack(alignment: .center, spacing: 16) {
            Image(.icEmptyOrder)
                .fixSize(200)
            Text("You have no order")
                .font(.titleH5)
                .foregroundStyle(.colorBaseTent)
            Text("Let's swap now")
                .font(.paragraphSmall)
                .foregroundStyle(.colorBaseTent)
        }
    }

    var emptySearch: some View {
        VStack(alignment: .center, spacing: 16) {
            Image(.icEmptyResult)
                .fixSize(120)
            Text("No results")
                .font(.labelMediumSecondary)
                .foregroundStyle(.colorBaseTent)
        }
    }
}


#Preview {
    OrderHistoryView()
        .environmentObject(AppSetting.shared)
}
