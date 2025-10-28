import SwiftUI

private struct Data {
    let title: String
    let description: String
}

struct CarouselView: View {
    private let data = [
        Data(
            title: "Get your first token now",
            description: "Let's grow your property"),
        Data(title: "Join the latest IDO today?", description: "Get your tokens early"),
        Data(title: "Join the latest IDO today?", description: "Get your tokens early"),
    ]

    @ObservedObject
    var homeViewModel: HomeViewModel
    @ObservedObject
    var tokenManager: TokenManager

    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .bottomLeading) {
                if !tokenManager.hasTokenOrNFT || homeViewModel.showSkeleton {
                    HStack(alignment: .center) {
                        VStack(alignment: .leading) {
                            Text(data.first?.title)
                                .font(.labelMediumSecondary)
                                .foregroundStyle(.colorBaseTent)
                            Spacer()
                                .frame(height: Spacing.xs)
                            Text(data.first?.description)
                                .font(.paragraphXSmall)
                                .foregroundStyle(.colorInteractiveTentPrimarySub)
                        }
                        .padding(.leading, Spacing.xl)

                        Spacer()

                        Image(.icFirstToken)
                            .resizable()
                            .frame(width: 61, height: 98)
                    }
                } else {
                    IndicatorView(count: data.count, scrollIndex: homeViewModel.scrollIndex)
                        .offset(x: Spacing.xl, y: -Spacing.xl)
                    TabView(selection: $homeViewModel.scrollIndex) {
                        ForEach(0..<data.count, id: \.self) {
                            index in
                            let item = data[index]
                            HStack(alignment: .top) {
                                VStack(alignment: .leading) {
                                    Text(item.title)
                                        .font(.labelMediumSecondary)
                                        .foregroundStyle(.colorBaseTent)
                                    Spacer()
                                        .frame(height: Spacing.xs)
                                    Text(item.description).font(.paragraphXSmall)
                                        .foregroundStyle(.colorInteractiveTentPrimarySub)
                                }
                                .padding(.top, Spacing.xl)
                                .padding(.leading, Spacing.xl)

                                Spacer()

                                Image(.comingSoon).resizable()
                                    .frame(
                                        width: 98, height: 98)
                            }
                        }
                    }
                    .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
                    .onChange(of: homeViewModel.scrollIndex) { newValue in
                        if newValue == data.count {
                            homeViewModel.scrollIndex = 0
                        } else if newValue == -1 {
                            homeViewModel.scrollIndex = data.count - 1
                        }
                    }
                }
            }
            .cornerRadius(BorderRadius._3xl)
            .overlay(
                RoundedRectangle(cornerRadius: BorderRadius._3xl).stroke(.colorBorderPrimarySub, lineWidth: 1)
            )
            .padding(0)
        }
    }
}

private struct IndicatorView: View {
    let count: Int
    let scrollIndex: Int

    var body: some View {
        HStack(spacing: Spacing.xs) {
            ForEach(0..<count, id: \.self) {
                indicator in
                let index = scrollIndex
                Rectangle()
                    .frame(
                        width: indicator == index ? 12 : 6, height: 4
                    )
                    .foregroundColor(
                        indicator == index
                            ? .colorInteractiveTentSecondarySub : .colorSurfacePrimaryDefault
                    )
                    .cornerRadius(BorderRadius.full)
                    .animation(.easeInOut(duration: 0.3), value: scrollIndex)
            }
        }
    }
}


#Preview {
    VStack(spacing: 0) {
        CarouselView(homeViewModel: HomeViewModel(), tokenManager: TokenManager.shared)
            .frame(height: 98)
            .padding(.horizontal, .xl)

    }
}
