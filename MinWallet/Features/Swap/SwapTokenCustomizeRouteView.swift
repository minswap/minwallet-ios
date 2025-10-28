import SwiftUI
import FlowStacks


struct SwapTokenCustomizedRouteView: View {
    @Environment(\.partialSheetDismiss)
    private var onDismiss

    private let columns = [
        GridItem(.flexible(), spacing: .xl),
        GridItem(.flexible(), spacing: .xl),
    ]

    private let items: [AggregatorSource] = AggregatorSource.allCases
    @Binding
    var excludedSource: [String: AggregatorSource]

    var onSave: (() -> Void)?

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("Customized Routing")
                .font(.titleH5)
                .frame(maxWidth: .infinity, alignment: .leading)
                .frame(height: 60)
                .padding(.top, .md)
                .padding(.horizontal, .xl)
            VStack(alignment: .leading, spacing: 4) {
                let count = AggregatorSource.allCases.count - excludedSource.count
                Text("Select All (\(count))")
                    .font(.labelMediumSecondary)
                    .foregroundStyle(.colorBaseTent)
                    .frame(height: 24)
                Text("For the best possible rates, this setting should be turned off if you are not familiar with it")
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .font(.paragraphSmall)
                    .foregroundStyle(.colorInteractiveTentPrimarySub)
            }
            .padding(.xl)
            .overlay(RoundedRectangle(cornerRadius: 16).stroke(.colorBorderPrimaryTer, lineWidth: 2))
            .padding(.horizontal, .xl)
            .padding(.bottom, .xl)
            .contentShape(.rect)
            .onTapGesture {
                excludedSource = [:]
            }
            ScrollView {
                LazyVGrid(columns: columns, spacing: .lg) {
                    ForEach(0..<items.count, id: \.self) { index in
                        SwapTokenCustomizedRouteItemView(source: items[index], excludedSource: $excludedSource)
                    }
                }
                .padding(.horizontal, .xl)
            }

            Spacer(minLength: 0)
            HStack(spacing: 16) {
                CustomButton(title: "Cancel", variant: .secondary) {
                    onDismiss?()
                }
                .frame(height: 56)
                CustomButton(title: "Save") {
                    onSave?()
                    onDismiss?()
                }
                .frame(height: 56)
            }
            .padding(.horizontal, .xl)
            .padding(.top, ._3xl)
            .padding(.bottom, .md)
        }
        .frame(height: (UIScreen.current?.bounds.height ?? 0) * 0.83)
        .presentSheetModifier()
    }
}


private struct SwapTokenCustomizedRouteItemView: View {
    @State var source: AggregatorSource
    @Binding var excludedSource: [String: AggregatorSource]

    var body: some View {
        VStack(alignment: .leading, spacing: .md) {
            HStack(spacing: 4) {
                let size = CGSize(width: 20, height: 20)
                ZStack {
                    Group {
                        Image(source.image)
                            .resizable()
                            .scaledToFit()
                    }
                    .frame(width: size.width, height: size.height)
                    .clipShape(Circle())
                    if source.isLocked {
                        Circle()
                            .fill(.colorBaseBackground)
                            .frame(width: size.width * 16 / 28, height: size.width * 16 / 28)
                            .overlay(
                                Image(.icLocked)
                                    .resizable()
                                    .frame(width: size.width * 12 / 28, height: size.width * 12 / 28)
                            )
                            .overlay(
                                Circle()
                                    .stroke(.colorSurfacePrimarySub, lineWidth: 1)
                            )
                            .position(x: size.width - 2, y: size.width - 2)
                    }
                }
                .frame(width: size.width, height: size.height)
                Spacer()
                if excludedSource[source.rawId] == nil || source.isLocked {
                    Image(.icChecked)
                }
            }
            Text(source.name)
                .font(.labelMediumSecondary)
                .foregroundStyle(.colorBaseTent)
                .frame(height: 20)
                .minimumScaleFactor(0.8)
        }
        .padding(.xl)
        .overlay(RoundedRectangle(cornerRadius: 20).stroke(excludedSource[source.rawId] == nil ? .colorInteractiveToneHighlight : .colorBorderPrimaryTer, lineWidth: 2))
        .contentShape(.rect)
        .onTapGesture {
            guard !source.isLocked else { return }
            if excludedSource[source.rawId] == nil {
                excludedSource[source.rawId] = source
            } else {
                excludedSource.removeValue(forKey: source.rawId)
            }
        }
        .padding(.top, 2)
    }
}

#Preview {
    SwapTokenCustomizedRouteView(excludedSource: .constant([:]))
        .environmentObject(SwapTokenViewModel(tokenReceive: nil))
}
