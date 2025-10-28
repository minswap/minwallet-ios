import SwiftUI


struct SwapTokenSettingView: View {
    enum Slippage: Double, CaseIterable, Identifiable {
        var id: Double { self.rawValue }

        case _01 = 0.1
        case _05 = 0.5
        case _1 = 1
        case _2 = 2
    }

    @State
    private var slippages: [Slippage] = Slippage.allCases
    @FocusState
    private var isFocus: Bool

    var onShowToolTip: ((_ title: LocalizedStringKey, _ content: LocalizedStringKey) -> Void)?

    private let maxValue: Double = 100.0  // Define the maximum value

    @Environment(\.partialSheetDismiss)
    private var onDismiss
    @Binding
    var showCustomizedRoute: Bool
    @Binding
    var swapTokenSetting: SwapTokenSetting

    var onSave: (() -> Void)?

    var body: some View {
        ZStack {
            VStack(spacing: 0) {
                Text("Slippage Tolerance")
                    .font(.labelSmallSecondary)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.top, 20)
                HStack(spacing: 0) {
                    ForEach(0..<slippages.count, id: \.self) { index in
                        if let splippage = slippages[gk_safeIndex: index] {
                            Text("\(splippage.rawValue.formatSNumber())%")
                                .font(.labelSmallSecondary)
                                .foregroundStyle(splippage == swapTokenSetting.slippageSelected ? .colorBaseBackground : .colorBaseTent)
                                .fixedSize(horizontal: true, vertical: false)
                                .frame(height: 36)
                                .padding(.horizontal, .lg)
                                .background(content: {
                                    RoundedRectangle(cornerRadius: BorderRadius.full).fill(splippage == swapTokenSetting.slippageSelected ? .colorInteractiveTentSecondaryDefault : .colorSurfacePrimaryDefault)
                                })
                                .contentShape(.rect)
                                .onTapGesture {
                                    swapTokenSetting.slippageSelected = splippage
                                }
                            Spacer()
                        }
                    }
                    HStack(spacing: .md) {
                        TextField("", text: $swapTokenSetting.slippageTolerance)
                            .keyboardType(.decimalPad)
                            .placeholder("Custom", when: swapTokenSetting.slippageTolerance.isEmpty)
                            .focused($isFocus)
                            .lineLimit(1)
                            .onChange(of: swapTokenSetting.slippageTolerance) { newValue in
                                swapTokenSetting.slippageTolerance = AmountTextField.formatCurrency(newValue, minValue: 0, maxValue: maxValue, minimumFractionDigits: 4)
                                swapTokenSetting.slippageSelected = nil
                            }
                        Text("%")
                            .font(.labelMediumSecondary)
                            .foregroundStyle(.colorInteractiveTentPrimarySub)
                            .fixedSize(horizontal: true, vertical: false)
                    }
                    .frame(height: 36)
                    .padding(.horizontal, .lg)
                    .overlay(RoundedRectangle(cornerRadius: BorderRadius.full).stroke(.colorBorderPrimaryDefault, lineWidth: 1))
                }
                .padding(.top, .md)
                if (Double(swapTokenSetting.slippageTolerance) ?? 0) >= 50 && swapTokenSetting.slippageSelected == nil && swapTokenSetting.safeMode {
                    HStack(spacing: Spacing.md) {
                        Image(.icWarning)
                            .resizable()
                            .frame(width: 16, height: 16)
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Unsafe slippage tolerance.")
                                .lineLimit(0)
                                .font(.paragraphSemi)
                                .foregroundStyle(.colorInteractiveToneDanger)
                            Text("Beware that using over 50% slippage is risky. It means that you are willing to accept a price movement of over 50% once your order is executed.")
                                .font(.paragraphXSmall)
                                .foregroundStyle(.colorInteractiveToneDanger)
                        }
                        Spacer(minLength: 0)
                    }
                    .padding(.md)
                    .background(
                        RoundedRectangle(cornerRadius: 8).fill(.colorInteractiveToneDanger8)
                    )
                    .padding(.top, .xl)
                }

                HStack(spacing: .xl) {
                    DashedUnderlineText(text: "Liquidity Source", textColor: .colorBaseTent, font: .labelSmallSecondary)

                    Spacer()

                    let count =
                        String(AggregatorSource.allCases.count - swapTokenSetting.excludedPools.count) + "/"
                        + String(
                            AggregatorSource.allCases.count
                        )
                    Text(count)
                        .foregroundStyle(.colorBaseTent)
                        .font(.paragraphSmall)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 4)
                        .overlay(
                            RoundedRectangle(cornerRadius: BorderRadius.full)
                                .stroke(.colorBorderPrimaryDefault, lineWidth: 1)
                        )
                    Image(.icNext)
                }
                .frame(height: 32)
                .padding(.top, .xl)
                .onTapGesture {
                    hideKeyboard()
                    $showCustomizedRoute.showSheet()
                }
                Color.colorBorderPrimaryDefault.frame(height: 1)
                    .padding(.vertical, .xl)
                VStack(spacing: .xs) {
                    HStack {
                        HStack(spacing: .md) {
                            Image(.icShieldCheck)
                                .resizable()
                                .frame(width: 16, height: 16)
                            Text("Safe Mode")
                                .font(.labelSmallSecondary)
                                .foregroundColor(.colorBaseTent)
                        }
                        Text("Recommended")
                            .font(.labelSmallSecondary)
                            .foregroundColor(.colorInteractiveToneSuccess)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 4)
                            .background(
                                RoundedRectangle(cornerRadius: BorderRadius.full)
                                    .fill(.colorSurfaceSuccess)
                            )
                        Spacer()
                        Toggle("", isOn: $swapTokenSetting.safeMode)
                            .toggleStyle(SwitchToggleStyle())
                    }

                    Text("Prevent high price impact trades. Disable at your own risk.")
                        .font(.paragraphSmall)
                        .foregroundColor(.colorInteractiveTentPrimarySub)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                Spacer()
                CustomButton(title: "Save") {
                    onSave?()
                    onDismiss?()
                }
                .frame(height: 56)
                .padding(.bottom, .md)
            }
            .padding(.horizontal, .xl)
            .background(.colorBaseBackground)
            .frame(height: (UIScreen.current?.bounds.height ?? 0) * 0.83)
            .presentSheetModifier()
        }
    }
}

#Preview {
    VStack {
        SwapTokenSettingView(showCustomizedRoute: .constant(false), swapTokenSetting: .constant(.init()))
            .padding(16)
        Spacer()
    }
    .background(Color.black)
}
