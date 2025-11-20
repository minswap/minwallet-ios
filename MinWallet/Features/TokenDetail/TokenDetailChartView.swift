import SwiftUI
import Charts


///https://blog.stackademic.com/line-chart-using-swift-charts-swiftui-cd1abeac9e44
enum LineChartType: String, CaseIterable, Plottable {
    case optimal = "Optimal"
    case outside = "Outside range"
    
    var color: Color {
        switch self {
        case .optimal: return .green
        case .outside: return .red
        }
    }
    
}

struct LineChartData: Hashable {
    var id = UUID()
    var date: Date
    var value: Double
    
    var type: LineChartType
}

extension TokenDetailView {
    var tokenDetailChartView: some View {
        VStack(alignment: .leading, spacing: 0) {
            let maxY: Double = (viewModel.chartDatas.map { $0.value }.max() ?? 0) * 1
            let minDate: Date = viewModel.chartDatas.map { $0.date }.min() ?? Date()
            let maxDate: Date = viewModel.chartDatas.map { $0.date }.max() ?? Date()
            let isShowNoData: Bool = !viewModel.isLoadingPriceChart && viewModel.chartDatas.isEmpty
            VStack(alignment: .leading, spacing: 0) {
                if isShowNoData {
                    VStack(alignment: .center, spacing: .xl) {
                        Image(.icNoChartData)
                            .resizable()
                            .frame(width: 160, height: 160)
                        Text("Chart is unavailable")
                            .font(.labelSemiSecondary)
                            .foregroundStyle(.colorBaseTent)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.top, -20)
                    .padding(.bottom, 27)
                } else {
                    Chart {
                        if let selectedIndex = viewModel.selectedIndex, viewModel.chartDatas.count > selectedIndex {
                            ForEach(0..<selectedIndex + 1, id: \.self) { index in
                                let data = viewModel.chartDatas[gk_safeIndex: index]
                                LineMark(
                                    x: .value("Date", data?.date ?? Date()),
                                    y: .value("Value", data?.value ?? 0)
                                )
                                .foregroundStyle(.colorInteractiveToneHighlight)
                                //.interpolationMethod(.catmullRom)
                                //.lineStyle(.init(lineWidth: 1))
                                .lineStyle(by: .value("Type", "PM2.5"))
                            }
                        }
                        if let selectedIndex = viewModel.selectedIndex, viewModel.chartDatas.count > selectedIndex {
                            ForEach(selectedIndex..<viewModel.chartDatas.count, id: \.self) { index in
                                let data = viewModel.chartDatas[gk_safeIndex: index]
                                LineMark(
                                    x: .value("Date", data?.date ?? Date()),
                                    y: .value("Value", data?.value ?? 0)
                                )
                                //.interpolationMethod(.catmullRom)
                                .foregroundStyle(viewModel.isInteracting ? .colorBorderPrimarySub : .colorInteractiveToneHighlight)
                            }
                        }
                        if let selectedIndex = viewModel.selectedIndex, viewModel.isInteracting, let data = viewModel.chartDatas[gk_safeIndex: selectedIndex] {
                            PointMark(
                                x: .value("Date", data.date),
                                y: .value("Value", data.value)
                            )
                            .symbolSize(60)
                            .foregroundStyle(.colorInteractiveToneHighlight)
                            if #available(iOS 17.0, *) {
                                RuleMark(x: .value("Date", data.date))
                                    .foregroundStyle(.colorInteractiveTentPrimarySub)
                                    .lineStyle(StrokeStyle(lineWidth: 1, dash: [5]))
                                    .annotation(
                                        position: .automatic, alignment: .top, spacing: 0, overflowResolution: .init(x: .fit, y: .fit),
                                        content: {
                                            VStack {
                                                Text("\(viewModel.formatDateAnnotation(value: data.date))")
                                                    .font(.paragraphXSmall)
                                                    .foregroundStyle(.colorBaseTent)
                                            }
                                            .background(.colorBaseBackground)
                                        })
                            } else {
                                RuleMark(x: .value("Date", data.date))
                                    .foregroundStyle(.colorInteractiveTentPrimarySub)
                                    .lineStyle(StrokeStyle(lineWidth: 1, dash: [5]))
                                    .annotation(
                                        position: .automatic, alignment: .top,
                                        content: {
                                            VStack {
                                                Text("\(viewModel.formatDateAnnotation(value: data.date))")
                                                    .font(.paragraphXSmall)
                                                    .foregroundStyle(.colorBaseTent)
                                            }
                                        })
                            }
                        }
                    }
                    .chartYAxis {
                        AxisMarks(preset: .extended, position: .leading) {
                            let value = $0.as(Double.self)!
                            AxisValueLabel {
                                Text(value.formatNumber(font: .paragraphXMediumSmall, fontColor: .colorInteractiveTentPrimaryDisable))
                            }
                        }
                    }
                    .chartYScale(domain: 0...maxY)
                    .chartXAxis(.hidden)
                    .chartLegend(.hidden)
                    .padding(.horizontal, .xl)
                    .chartOverlay { chart in
                        GeometryReader { geometry in
                            Rectangle()
                                .fill(Color.clear)
                                .contentShape(Rectangle())
                                .gesture(
                                    DragGesture(minimumDistance: 0, coordinateSpace: .global)
                                        .onChanged { value in
                                            guard !viewModel.chartDatas.isEmpty else { return }
                                            self.viewModel.isInteracting = true
                                            updateSelectedIndex(using: chart, at: value.location, in: geometry)
                                        }
                                        .onEnded { _ in
                                            guard !viewModel.chartDatas.isEmpty else { return }
                                            self.viewModel.isInteracting = false
                                            self.viewModel.selectedIndex = viewModel.chartDatas.count - 1
                                        })
                            /*
                             .gesture(
                             LongPressGesture(minimumDuration: 2)
                             .onChanged { _ in
                             guard !self.viewModel.isInteracting else { return }
                             self.viewModel.isInteracting = true
                             self.triggerVibration()
                             }
                             .onEnded { _ in
                             // When the long press ends, set interaction flag to false
                             self.viewModel.isInteracting = false
                             self.viewModel.selectedIndex = viewModel.chartDatas.count - 1
                             }
                             .simultaneously(
                             with: DragGesture(minimumDistance: 0)
                             .onChanged { value in
                             guard viewModel.isInteracting else { return }
                             updateSelectedIndex(using: chart, at: value.location, in: geometry)
                             }
                             .onEnded { _ in
                             self.viewModel.isInteracting = false
                             self.viewModel.selectedIndex = viewModel.chartDatas.count - 1
                             }
                             )
                             )
                             */
                        }
                    }
                    .frame(height: 180)
                    HStack {
                        Text(viewModel.formatDate(value: minDate))
                            .font(.paragraphXMediumSmall)
                            .foregroundStyle(.colorInteractiveTentPrimaryDisable)
                        Spacer()
                        Text(viewModel.formatDate(value: maxDate))
                            .font(.paragraphXMediumSmall)
                            .foregroundStyle(.colorInteractiveTentPrimaryDisable)
                    }
                    .padding(.top, .md)
                    .padding(.horizontal, .xl)
                }
            }
            .loading(isShowing: $viewModel.isLoadingPriceChart)
            .animation(.default, value: viewModel.chartDatas)
            HStack(spacing: 0) {
                ForEach(viewModel.chartPeriods, id: \.self) { period in
                    if viewModel.chartPeriod == period {
                        Text(period.title)
                            .font(.labelSmallSecondary)
                            .foregroundStyle(.colorInteractiveTentSecondaryDefault)
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                            .background(RoundedRectangle(cornerRadius: BorderRadius.full).fill(.colorBaseBackground))
                            .compositingGroup()
                            .shadow(color: .colorBaseTent.opacity(0.1), radius: 2, x: 0, y: 2)
                            .padding(.vertical, .xs)
                            .contentShape(.rect)
                            .onTapGesture {
                                viewModel.chartPeriod = period
                            }
                    } else {
                        Text(period.title)
                            .font(.labelSmallSecondary)
                            .foregroundStyle(.colorInteractiveTentSecondaryDefault)
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                            .contentShape(.rect)
                            .onTapGesture {
                                viewModel.chartPeriod = period
                            }
                    }
                }
            }
            .padding(.horizontal, 4)
            .frame(height: 36)
            .background(RoundedRectangle(cornerRadius: BorderRadius.full).fill(.colorSurfacePrimarySub))
            .padding(.top, .xl)
            .padding(.horizontal, .xl)
        }
    }
    
    private func updateSelectedIndex(using proxy: ChartProxy, at location: CGPoint, in geometry: GeometryProxy) {
        let xPosition = location.x - geometry[proxy.plotAreaFrame].origin.x
        guard let date: Date = proxy.value(atX: xPosition) else { return }
        
        let closestIndex = viewModel.chartDatas.indices.min(by: {
            abs(viewModel.chartDatas[$0].date.timeIntervalSince1970 - date.timeIntervalSince1970) < abs(viewModel.chartDatas[$1].date.timeIntervalSince1970 - date.timeIntervalSince1970)
        })
        
        viewModel.selectedIndex = closestIndex
    }
    
    private func triggerVibration() {
        // Trigger a haptic feedback when the long press begins
        let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
        impactFeedback.prepare()
        impactFeedback.impactOccurred()
    }
}

extension Date {
    func adding(_ component: Calendar.Component, value: Int, using calendar: Calendar = .current) -> Date? {
        return calendar.date(byAdding: component, value: value, to: self)
    }
    
    var startOfDay: Date {
        var calendar = Calendar(identifier: .gregorian)
        if AppSetting.shared.timeZone == AppSetting.TimeZone.utc.rawValue {
            calendar.timeZone = .gmt
            calendar.locale = Locale(identifier: "en_US_POSIX")
            
        }
        return calendar.startOfDay(for: self)
    }
    
    var endOfDay: Date {
        return self.startOfDay.addingTimeInterval(86400 - 1)
    }
}


#Preview {
    TokenDetailView(viewModel: TokenDetailViewModel(token: TokenProtocolDefault()))
        .environmentObject(AppSetting.shared)
}
