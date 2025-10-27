import SwiftUI


struct TokenDetailToolTipView: View {
    
    @Binding
    var title: LocalizedStringKey
    @Binding
    var content: LocalizedStringKey
    
    private var isRiskScore: Bool {
        let raw: LocalizedStringKey = "Powered by Xerberus. This is for informational purposes only and is not intended to be used as financial advice. User Agreement"
        guard content == raw else { return false }
        return true
    }
    
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
                if isRiskScore {
                    Text(generateContentRiskScore())
                        .lineSpacing(2)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.top, .lg)
                        .padding(.bottom, .md)
                        .contentShape(.rect)
                        .onTapGesture {
                            "https://www.xerberus.io/terms-conditions".openURL()
                        }
                } else {
                    Text(content)
                        .font(.labelRegular)
                        .foregroundStyle(.colorInteractiveTentPrimarySub)
                        .lineSpacing(2)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.top, .lg)
                        .padding(.bottom, .md)
                        .contentShape(.rect)
                }
            }
            .padding(.horizontal, .xl)
        }
        .fixedSize(horizontal: false, vertical: true)
    }
    
    private func generateContentRiskScore() -> AttributedString {
        let local: LocalizedStringKey = "Powered by Xerberus. This is for informational purposes only and is not intended to be used as financial advice. "
        let localAgreement: LocalizedStringKey = "User Agreement."
        var attribue: AttributedString = AttributedString(local.toString()).build(font: .labelRegular, color: .colorInteractiveTentPrimarySub)
        var agreement: AttributedString = AttributedString(localAgreement.toString()).build(font: .labelRegular, color: .colorInteractiveToneHighlight)
        agreement.underlineStyle = .single
        attribue.append(agreement)
        return attribue
    }
}

/*
#Preview {
    VStack {
        TokenDetailToolTipView()
        Spacer()
    }
}
*/
