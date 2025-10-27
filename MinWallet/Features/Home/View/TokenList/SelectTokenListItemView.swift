import SwiftUI


struct SelectTokenListItemView: View {
    private let token: TokenProtocol?
    @Binding
    private var isSelected: Bool
    @State
    private var isShowSelected: Bool = false
    @Binding
    private var isFav: Bool
    
    init(token: TokenProtocol?, isSelected: Binding<Bool>, isShowSelected: Bool, isFav: Bool = false) {
        self.token = token
        self._isSelected = isSelected
        self._isShowSelected = .init(wrappedValue: isShowSelected)
        self._isFav = .constant(isFav)
    }
    
    var body: some View {
        HStack(spacing: .md) {
            TokenLogoView(currencySymbol: token?.currencySymbol, tokenName: token?.tokenName, isVerified: token?.isVerified, isFav: isFav)
            let adaName = token?.adaName
            let name = token?.projectName ?? ""
            let amount = token?.amount ?? 0
            VStack(alignment: .leading, spacing: 4) {
                Text(adaName)
                    .font(.labelMediumSecondary)
                    .foregroundStyle(.colorBaseTent)
                    .layoutPriority(1000)
                Text(name.isBlank ? adaName : name)
                    .font(.paragraphSmall)
                    .foregroundStyle(.colorInteractiveTentPrimarySub)
                    .lineLimit(1)
                    .padding(.trailing, .md)
                    .layoutPriority(998)
            }
            .padding(.vertical, 14)
            Spacer(minLength: 0)
            Text(amount.formatNumber())
                .font(.labelMediumSecondary)
                .foregroundStyle(.colorBaseTent)
                .minimumScaleFactor(0.5)
                .layoutPriority(999)
            if isShowSelected {
                Image(isSelected ? .icChecked : .icUnchecked)
                    .fixSize(20)
                    .padding(.leading, 4)
            }
        }
        .overlay(
            Rectangle().frame(height: 1).foregroundColor(.colorBorderItem), alignment: .bottom
        )
        .padding(.horizontal, 16)
        .background {
            if isShowSelected {
                return Color.clear
            }
            
            return isSelected ? Color.colorBorderPrimaryTer : Color.clear
        }
    }
}

#Preview {
    SelectTokenListItemView(
        token: TokenManager.shared.tokenAda,
        isSelected: .constant(true),
        isShowSelected: true
    )
    .environmentObject(AppSetting.shared)
}
