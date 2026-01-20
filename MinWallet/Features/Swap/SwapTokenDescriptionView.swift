import SwiftUI


struct SwapTokenDescriptionView: View {
    
    var onDismiss: (() -> Void)?
    
    var body: some View {
        VStack(spacing: 8) {
            VStack(spacing: 0) {
                Color.colorBorderPrimaryDefault.frame(width: 36, height: 4).cornerRadius(2, corners: .allCorners)
                    .padding(.vertical, .md)
                Text("Alert")
                    .font(.titleH5)
                    .foregroundStyle(.colorBaseTent)
                    .frame(maxWidth: .infinity, minHeight: 60, alignment: .leading)
                VStack(alignment: .leading, spacing: 4) {
                    HStack(
                        alignment: .top,
                        content: {
                            Circle().frame(width: 5, height: 5)
                                .foregroundStyle(.colorBaseTent)
                                .padding(.top, 8)
                            Text("Swaps are executed by third-party Cardano protocols.")
                                .font(.labelRegular)
                                .foregroundStyle(.colorBaseTent)
                                .lineSpacing(2)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .contentShape(.rect)
                        })
                    HStack(
                        alignment: .top,
                        content: {
                            Circle().frame(width: 5, height: 5)
                                .foregroundStyle(.colorBaseTent)
                                .padding(.top, 8)
                            Text("MinWallet only helps you sign transactions and does not operate an exchange or hold funds.")
                                .font(.labelRegular)
                                .foregroundStyle(.colorBaseTent)
                                .lineSpacing(2)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .contentShape(.rect)
                        })
                }
                .padding(.horizontal, 6)
                .padding(.vertical, .lg)
                
                CustomButton(title: "Close", variant: .secondary) {
                    onDismiss?()
                }
                .frame(height: 56)
                .padding(.top, 24)
                .padding(.bottom, .md)
            }
            .padding(.horizontal, .xl)
        }
        .fixedSize(horizontal: false, vertical: true)
    }
}


#Preview {
    VStack {
        SwapTokenDescriptionView()
        Spacer()
    }
}
