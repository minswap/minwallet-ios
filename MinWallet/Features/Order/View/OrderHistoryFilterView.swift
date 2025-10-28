import SwiftUI
import FlowStacks
import Then
import SwiftyAttributes


struct OrderHistoryFilterView: View {
    @EnvironmentObject
    private var appSetting: AppSetting
    @ObservedObject
    var viewModel: OrderHistoryFilterViewModel

    @Environment(\.partialSheetDismiss)
    var onDismiss

    var onFilterSelected: ((AggrSource?, OrderV2Status?, AggregatorSource?, OrderHistory.OrderType?, Date?, Date?) -> Void)?

    private func formateDate(_ date: Date?) -> String {
        guard let date = date else { return "Select date" }
        let formatter = DateFormatter()
        formatter.dateFormat = "dd-MM-YYYY"
        if AppSetting.shared.timeZone == AppSetting.TimeZone.utc.rawValue {
            formatter.timeZone = .gmt
            formatter.locale = Locale(identifier: "en_US_POSIX")
        }
        return formatter.string(from: date)
    }

    private static let heightExpand: CGFloat = (UIScreen.current?.bounds.height ?? 0) * 0.85
    private static let heightCollapse: CGFloat = 450

    var body: some View {
        VStack(spacing: 0) {
            Text("Filter")
                .font(.titleH5)
                .frame(maxWidth: .infinity, alignment: .leading)
                .frame(height: 60)
                .padding(.horizontal, .xl)
            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    if !viewModel.showSelectToDate && !viewModel.showSelectFromDate {
                        VStack(spacing: 0) {
                            Text("Aggregator Source")
                                .font(.labelSmallSecondary)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(.bottom, .md)
                            let allKeyType: LocalizedStringKey = "All"
                            let filterSource = ([allKeyType] + AggrSource.allCases.map({ $0.title })).map { $0.toString() }
                            FlexibleView(
                                data: filterSource,
                                spacing: 0,
                                alignment: .leading
                            ) { title in
                                let action = AggrSource(title: title)
                                let isActionAll = title == allKeyType.toString()
                                let content: LocalizedStringKey? = isActionAll ? allKeyType : action?.title
                                return TextSelectable(
                                    content: content ?? allKeyType,
                                    selected: $viewModel.filterSourceSelected,
                                    value: isActionAll ? nil : action
                                )
                                .onTapGesture {
                                    viewModel.filterSourceSelected = title == allKeyType.toString() ? nil : action
                                }
                            }
                            Color.colorBorderPrimarySub.frame(height: 1).padding(.vertical, .xl)
                            Text("Protocol")
                                .font(.labelSmallSecondary)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(.bottom, .md)
                            let rawActionsP: [AggregatorSource] = [
                                .Minswap,
                                .MinswapV2,
                                .MinswapStable,
                                .Splash,
                                .SplashStable,
                                .Spectrum,
                                .SundaeSwapV3,
                                .SundaeSwap,
                                .VyFinance,
                                .WingRidersV2,
                                .WingRiders,
                                .WingRidersStableV2,
                                .MuesliSwap,
                                .CSwap,
                            ]
                            //let rawActionsP: [AggregatorSource] = AggregatorSource.allCases
                            let allKeyP: LocalizedStringKey = "All"
                            let actionsP: [String] = ([allKeyP] + rawActionsP.map({ $0.name })).map { $0.toString() }

                            let heightz = calculateHeightFlowLayout(actions: actionsP)
                            FlowLayout(
                                mode: .vstack,
                                items: actionsP,
                                itemSpacing: 0
                            ) { title in
                                let action = AggregatorSource(title: title)
                                let isActionAll = title == allKeyP.toString()
                                let content: LocalizedStringKey? = isActionAll ? allKeyP : action?.name
                                TextSelectable(
                                    content: content ?? allKeyP,
                                    selected: $viewModel.protocolSelected,
                                    value: isActionAll ? nil : action
                                )
                                .onTapGesture {
                                    viewModel.protocolSelected = title == allKeyP.toString() ? nil : action
                                }
                            }
                            .frame(height: heightz)
                            Color.colorBorderPrimarySub.frame(height: 1)
                                .padding(.bottom, .xl)
                            Text("Action")
                                .font(.labelSmallSecondary)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(.bottom, .md)
                            let rawAction: [OrderHistory.OrderType] = [.swap, .limit, .zapIn, .zapOut, .deposit, .withdraw, .oco, .stopLoss, .partialSwap]
                            let allKey: LocalizedStringKey = "All"
                            let actions: [String] = ([allKey] + rawAction.map({ $0.titleFilter })).map { $0.toString() }

                            let height = calculateHeightFlowLayout(actions: actions)
                            FlowLayout(
                                mode: .vstack,
                                items: actions,
                                itemSpacing: 0
                            ) { title in
                                let action = OrderHistory.OrderType(title: title)
                                let isActionAll = title == allKey.toString()
                                let content: LocalizedStringKey? = isActionAll ? allKey : action?.titleFilter
                                TextSelectable(
                                    content: content ?? allKey,
                                    selected: $viewModel.actionSelected,
                                    value: isActionAll ? nil : action
                                )
                                .onTapGesture {
                                    viewModel.actionSelected = title == allKey.toString() ? nil : action
                                }
                            }
                            .frame(height: height)
                            .padding(.bottom, .md)
                            Text("Status")
                                .font(.labelSmallSecondary)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(.bottom, .md)

                            let statuses = ([allKey] + OrderV2Status.allCases.map({ $0.title })).map { $0.toString() }
                            FlexibleView(
                                data: statuses,
                                spacing: 0,
                                alignment: .leading
                            ) { title in
                                let action = OrderV2Status(title: title)
                                let isActionAll = title == allKey.toString()
                                let content: LocalizedStringKey? = isActionAll ? allKey : action?.title
                                return TextSelectable(
                                    content: content ?? allKey,
                                    selected: $viewModel.statusSelected,
                                    value: isActionAll ? nil : action
                                )
                                .onTapGesture {
                                    viewModel.statusSelected = title == allKey.toString() ? nil : action
                                }
                            }
                            Color.colorBorderPrimarySub.frame(height: 1).padding(.vertical, .xl)
                        }
                        .padding(.top, .lg)
                    }
                    HStack(spacing: .xl) {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("From")
                                .font(.labelSmallSecondary)
                                .foregroundStyle(.colorBaseTent)
                                .frame(maxWidth: .infinity, alignment: .leading)
                            Text(formateDate(viewModel.fromDate))
                                .font(.paragraphSmall)
                                .foregroundStyle(.colorBaseTent)
                                .padding(EdgeInsets(top: 0, leading: 16, bottom: 0, trailing: 16))
                                .frame(maxWidth: .infinity, minHeight: 44)
                                .overlay(
                                    RoundedRectangle(cornerRadius: BorderRadius.full)
                                        .stroke(viewModel.showSelectFromDate ? .colorBorderPrimaryPressed : .colorBorderPrimaryDefault, lineWidth: viewModel.showSelectFromDate ? 2 : 1)
                                )
                                .onTapGesture {
                                    guard !viewModel.showSelectFromDate else {
                                        viewModel.showSelectToDate = false
                                        viewModel.showSelectFromDate = false
                                        return
                                    }
                                    viewModel.showSelectToDate = false
                                    viewModel.showSelectFromDate = true
                                }
                        }

                        VStack(alignment: .leading, spacing: 4) {
                            Text("To")
                                .font(.labelSmallSecondary)
                                .foregroundStyle(.colorBaseTent)
                                .frame(maxWidth: .infinity, alignment: .leading)
                            Text(formateDate(viewModel.toDate))
                                .font(.paragraphSmall)
                                .foregroundStyle(.colorBaseTent)
                                .padding(EdgeInsets(top: 0, leading: 16, bottom: 0, trailing: 16))
                                .frame(maxWidth: .infinity, minHeight: 44)
                                .overlay(
                                    RoundedRectangle(cornerRadius: BorderRadius.full)
                                        .stroke(viewModel.showSelectToDate ? .colorBorderPrimaryPressed : .colorBorderPrimaryDefault, lineWidth: viewModel.showSelectToDate ? 2 : 1)
                                )
                                .onTapGesture {
                                    guard !viewModel.showSelectToDate else {
                                        viewModel.showSelectToDate = false
                                        viewModel.showSelectFromDate = false
                                        return
                                    }
                                    viewModel.showSelectToDate = true
                                    viewModel.showSelectFromDate = false
                                }
                        }
                    }
                    .padding(.top, (viewModel.showSelectToDate || viewModel.showSelectFromDate) ? .lg : 0)
                    if !viewModel.showSelectToDate && !viewModel.showSelectFromDate {
                        Color.clear.frame(height: 1).padding(.vertical, .xl)
                    }
                    if viewModel.showSelectFromDate || viewModel.showSelectToDate {
                        let timeZone: TimeZone = appSetting.timeZone == AppSetting.TimeZone.utc.rawValue ? .gmt : .current
                        VStack(alignment: .center) {
                            if viewModel.showSelectFromDate {
                                let fromDateBinding = Binding<Date>(
                                    get: { viewModel.fromDate ?? Date() },
                                    set: { newValue in
                                        viewModel.fromDate = newValue
                                    }
                                )
                                DatePicker(
                                    " ",
                                    selection: fromDateBinding,
                                    in: (viewModel.toDate ?? Date()).adding(.year, value: -20)!...(viewModel.toDate ?? Date()),
                                    displayedComponents: [.date]
                                )
                                .labelsHidden()
                                .datePickerStyle(.wheel)
                                .frame(minWidth: 0, maxWidth: .infinity, alignment: .center)
                                .environment(\.timeZone, timeZone)
                                .id(viewModel.fromDate)
                            }
                            if viewModel.showSelectToDate {
                                let toDateBinding = Binding<Date>(
                                    get: { viewModel.toDate ?? Date() },
                                    set: { newValue in
                                        viewModel.toDate = newValue
                                    }
                                )
                                DatePicker(
                                    " ",
                                    selection: toDateBinding,
                                    in: (viewModel.fromDate ?? Date())...(viewModel.fromDate ?? Date()).adding(.year, value: 20)!,
                                    displayedComponents: [.date]
                                )
                                .labelsHidden()
                                .datePickerStyle(.wheel)
                                .frame(minWidth: 0, maxWidth: .infinity, alignment: .center)
                                .environment(\.timeZone, timeZone)
                                .id(viewModel.toDate)
                            }
                        }
                    }
                    Spacer(minLength: 0)
                }
                .padding(.horizontal, .xl)
            }
            HStack(spacing: .xl) {
                CustomButton(title: "Reset", variant: .secondary) {
                    onDismiss?()
                    onFilterSelected?(nil, nil, nil, nil, nil, nil)
                    DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(1200)) {
                        viewModel.showSelectToDate = false
                        viewModel.showSelectFromDate = false
                    }
                }
                .frame(height: 56)
                CustomButton(title: "Apply") {
                    if viewModel.showSelectToDate || viewModel.showSelectFromDate {
                        if viewModel.showSelectToDate && viewModel.toDate == nil {
                            viewModel.toDate = Date().endOfDay
                        }
                        if viewModel.showSelectFromDate && viewModel.fromDate == nil {
                            viewModel.fromDate = Date().startOfDay
                        }
                        viewModel.showSelectToDate = false
                        viewModel.showSelectFromDate = false
                        return
                    }
                    onDismiss?()
                    viewModel.fromDate = viewModel.fromDate?.startOfDay
                    viewModel.toDate = viewModel.toDate?.endOfDay
                    onFilterSelected?(
                        viewModel.filterSourceSelected,
                        viewModel.statusSelected,
                        viewModel.protocolSelected,
                        viewModel.actionSelected,
                        viewModel.fromDate,
                        viewModel.toDate
                    )
                }
                .frame(height: 56)
            }
            .padding(.vertical, .md)
            .padding(.horizontal, .xl)
        }
        .frame(height: !viewModel.showSelectToDate && !viewModel.showSelectFromDate ? Self.heightExpand : Self.heightCollapse)
        .presentSheetModifier()
    }
}

#Preview {
    VStack {
        OrderHistoryFilterView(viewModel: OrderHistoryFilterViewModel())
        Spacer()
    }
    .environmentObject(AppSetting.shared)
}

private struct TextSelectable<T: Equatable>: View {
    @State var content: LocalizedStringKey = "All"
    @Binding var selected: T?
    @State var value: T?

    var body: some View {
        Text(content)
            .font(.labelSmallSecondary)
            .foregroundStyle(value == selected ? .colorInteractiveToneTent : .colorInteractiveTentPrimarySub)
            .padding(.horizontal, .lg)
            .padding(.vertical, 6)
            .frame(height: 32)
            .background(value == selected ? .colorInteractiveToneHighlight : .clear)
            .overlay(RoundedRectangle(cornerRadius: BorderRadius.full).stroke(value == selected ? .clear : .colorBorderPrimarySub, lineWidth: 1))
            .cornerRadius(BorderRadius.full)
            .lineLimit(1)
            .minimumScaleFactor(0.1)
            .contentShape(.rect)
            .padding(.trailing, .md)
            .padding(.bottom, .md)
    }
}

extension OrderHistoryFilterView {
    private func calculateHeightFlowLayout(actions: [String]) -> CGFloat {
        let actionsWidths = actions.map { action in
            NSMutableAttributedString()
                .then {
                    $0.append(
                        action
                            .withAttributes([
                                .font(.labelSmallSecondary ?? .systemFont(ofSize: 14, weight: .medium))
                            ]))
                }
                .gkWidth(consideringHeight: 32) + .lg * 2 + .md + 1
        }
        let maxWidth: CGFloat = UIScreen.main.bounds.width - .xl * 2 - 1
        var currentWidth: CGFloat = 0
        var row: CGFloat = 1
        for width in actionsWidths {
            if currentWidth + width <= maxWidth {
                currentWidth += width
            } else {
                row += 1
                currentWidth = width
            }
        }
        return row * 32 + row * .md
    }
}
