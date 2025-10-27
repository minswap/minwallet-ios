import SwiftUI
import FlowStacks


extension OrderHistoryView {
    var headerView: some View {
        HStack(alignment: .center, spacing: .md) {
            if viewModel.showSearch {
                HStack(alignment: .center, spacing: 0) {
                    HStack(spacing: .md) {
                        Image(.icSearch)
                            .resizable()
                            .frame(width: 20, height: 20)
                        TextField("", text: $viewModel.keyword)
                            .placeholder("Search by token name, txID", when: viewModel.keyword.isEmpty)
                            .focused($isFocus)
                            .lineLimit(1)
                            .keyboardType(.asciiCapable)
                            .submitLabel(.done)
                            .autocorrectionDisabled()
                        if !viewModel.keyword.isEmpty {
                            Image(.icCloseFill)
                                .resizable()
                                .frame(width: 20, height: 20)
                                .onTapGesture {
                                    viewModel.keyword = ""
                                }
                        }
                    }
                    .padding(.md)
                    .overlay(
                        RoundedRectangle(cornerRadius: BorderRadius.full)
                            .stroke(isFocus ? .colorBorderPrimaryPressed : .colorBorderPrimaryDefault, lineWidth: isFocus ? 2 : 1)
                    )
                    Text("Cancel")
                        .padding(.horizontal, .xl)
                        .padding(.vertical, 6)
                        .contentShape(.rect)
                        .onTapGesture {
                            hideKeyboard()
                            withAnimation {
                                viewModel.keyword = ""
                                viewModel.showSearch = false
                            }
                        }
                }
                .transition(.move(edge: .trailing).combined(with: .opacity))
            } else {
                Button(
                    action: {
                        navigator.pop()
                    },
                    label: {
                        Image(.icBack)
                            .fixSize(._3xl)
                            .padding(.md)
                            .background(RoundedRectangle(cornerRadius: BorderRadius.full).stroke(.colorBorderPrimaryTer, lineWidth: 1))
                    }
                )
                .buttonStyle(.plain)
                .padding(.trailing, .xs)
                let offset = scrollOffset.y
                let heightOrders = Self.heightOrder
                let opacity = abs(max(0, min(1, (offset - heightOrders / 2) / (heightOrders / 2))))
                Text("Orders")
                    .foregroundStyle(.colorBaseTent)
                    .font(.labelMediumSecondary)
                    .opacity((Self.heightOrder / 2 - offset) < 0 ? (opacity) : 0)
                Spacer()
                HStack(spacing: .md) {
                    Image(.icSearchOrder)
                        .fixSize(40)
                        .onTapGesture {
                            withAnimation {
                                viewModel.showSearch = true
                                isFocus = true
                            }
                        }
                    
                    ZStack {
                        Image(.icFilter)
                            .fixSize(40)
                        let countFilter = viewModel.countFilter
                        if countFilter > 0 {
                            Text("\(countFilter)")
                                .font(.paragraphXMediumSmall)
                                .foregroundStyle(.colorBaseTentNoDarkMode)
                                .frame(width: 16, height: 16)
                                .background(
                                    Circle()
                                        .fill(.colorFillFilter)
                                )
                                .position(x: 34, y: 32)
                        }
                    }
                    .contentShape(.rect)
                    .frame(width: 40, height: 40)
                    .onTapGesture {
                        withAnimation {
                            filterViewModel.bindData(vm: viewModel)
                            viewModel.showFilterView = true
                        }
                    }
                    .zIndex(999)
                }
                .transition(.scale.combined(with: .opacity))
            }
        }
        .padding(.horizontal, .xl)
        .background(.colorBaseBackground)
    }
}


#Preview {
    OrderHistoryView()
        .environmentObject(AppSetting.shared)
}
