import SwiftUI


struct OrderHistoryConfirmCancelView: View {
    
    @Environment(\.partialSheetDismiss)
    private var onDismiss
    
    var onCancelOrder: (() -> Void)?
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("Warning")
                .font(.titleH5)
                .frame(maxWidth: .infinity, alignment: .leading)
                .frame(height: 60)
                .padding(.horizontal, .xl)
            Image(.icWarningCancel)
                .fixSize(40)
                .padding(.top, .lg)
                .padding(.horizontal, .xl)
            Text("Are you sure you want to cancel this order?")
                .font(.labelMediumSecondary)
                .foregroundStyle(.colorBaseTent)
                .padding(.top, .xl)
                .padding(.horizontal, .xl)
            Text("You will have to pay a small fees to cancel your orders. Are you sure to continue?")
                .font(.labelRegular)
                .foregroundStyle(.colorInteractiveTentPrimarySub)
                .lineSpacing(2)
                .padding(.top, .lg)
                .padding(.horizontal, .xl)
            
            HStack(spacing: .xl) {
                CustomButton(title: "Dismiss", variant: .secondary) {
                    onDismiss?()
                }
                .frame(height: 56)
                CustomButton(
                    title: "Yes, cancel",
                    variant: .other(
                        textColor: .colorBaseTent,
                        backgroundColor: .colorInteractiveDangerDefault,
                        borderColor: .clear,
                        textColorDisable: .colorSurfaceDangerPressed,
                        backgroundColorDisable: .colorSurfaceDanger
                    )
                ) {
                    onDismiss?()
                    onCancelOrder?()
                }
                .frame(height: 56)
            }
            .padding(.top, 40)
            .padding(.horizontal, .xl)
            .padding(.bottom, .md)
        }
        .presentSheetModifier()
    }
    
}
#Preview {
    VStack {
        Spacer()
        OrderHistoryConfirmCancelView()
    }
}
