import SwiftUI

struct TimeZoneView: View {
    @EnvironmentObject
    var appSetting: AppSetting
    @Environment(\.partialSheetDismiss)
    var onDismiss
    
    var body: some View {
        VStack(spacing: 8) {
            VStack(spacing: 0) {
                Color.colorBorderPrimaryDefault.frame(width: 36, height: 4).cornerRadius(2, corners: .allCorners)
                    .padding(.vertical, .md)
                Text("Timezone")
                    .font(.titleH5)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .frame(height: 60)
                HStack(spacing: 16) {
                    Text("Local")
                        .font(.paragraphSmall)
                        .foregroundStyle(appSetting.timeZone == AppSetting.TimeZone.local.rawValue ? .colorInteractiveToneHighlight : .colorBaseTent)
                    Spacer()
                    Image(.icChecked)
                        .opacity(appSetting.timeZone == AppSetting.TimeZone.local.rawValue ? 1 : 0)
                }
                .frame(height: 52)
                .contentShape(.rect)
                .onTapGesture {
                    appSetting.timeZone = AppSetting.TimeZone.local.rawValue
                }
                HStack(spacing: 16) {
                    Text("UTC")
                        .font(.paragraphSmall)
                        .foregroundStyle(appSetting.timeZone == AppSetting.TimeZone.utc.rawValue ? .colorInteractiveToneHighlight : .colorBaseTent)
                    Spacer()
                    Image(.icChecked)
                        .opacity(appSetting.timeZone == AppSetting.TimeZone.utc.rawValue ? 1 : 0)
                }
                .frame(height: 52)
                .padding(.bottom, .xl)
                .contentShape(.rect)
                .onTapGesture {
                    appSetting.timeZone = AppSetting.TimeZone.utc.rawValue
                }
            }
            .padding(.horizontal, .xl)
            .background(content: {
                RoundedRectangle(cornerRadius: 24).fill(Color.colorBaseBackground)
            })
            Button(
                action: {
                    onDismiss?()
                },
                label: {
                    Text("Close")
                        .font(.labelMediumSecondary)
                        .foregroundStyle(.colorInteractiveTentSecondaryDefault)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .background(content: {
                            RoundedRectangle(cornerRadius: 24).fill(Color.colorBaseBackground)
                        })
                }
            )
            .frame(height: 56)
            .buttonStyle(.plain)
        }
        .fixedSize(horizontal: false, vertical: /*@START_MENU_TOKEN@*/ true /*@END_MENU_TOKEN@*/)
    }
}

#Preview {
    VStack {
        TimeZoneView()
            .environmentObject(AppSetting.shared)
        Spacer()
    }
    .background(Color.black)
}
