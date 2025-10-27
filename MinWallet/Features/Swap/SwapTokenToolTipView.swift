import SwiftUI


struct SwapTokenToolTipView: View {
    
    @Binding
    var title: LocalizedStringKey
    @Binding
    var content: LocalizedStringKey
    
    var body: some View {
        VStack(spacing: 8) {
            VStack(spacing: 0) {
                Color.colorBorderPrimaryDefault.frame(width: 36, height: 4).cornerRadius(2, corners: .allCorners)
                    .padding(.vertical, .md)
                Text(title)
                    .font(.titleH5)
                    .foregroundStyle(.colorBaseTent)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.top, .lg)
                    .padding(.bottom, .xl)
                Text(content)
                    .font(.labelRegular)
                    .foregroundStyle(.colorInteractiveTentPrimarySub)
                    .lineSpacing(2)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.top, .lg)
                    .padding(.bottom, .md)
                    .contentShape(.rect)
            }
            .padding(.horizontal, .xl)
        }
        .fixedSize(horizontal: false, vertical: true)
    }
}
