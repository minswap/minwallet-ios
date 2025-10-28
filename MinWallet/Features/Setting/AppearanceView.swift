import SwiftUI

struct AppearanceView: View {
    @EnvironmentObject
    private var appSetting: AppSetting
    @Environment(\.partialSheetDismiss)
    private var onDismiss
    @Environment(\.colorScheme)
    private var colorScheme: ColorScheme

    var body: some View {
        VStack(spacing: 8) {
            VStack(spacing: 0) {
                Color.colorBorderPrimaryDefault.frame(width: 36, height: 4).cornerRadius(2, corners: .allCorners)
                    .padding(.vertical, .md)
                Text("Appearance")
                    .font(.titleH5)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .frame(height: 60)
                    .padding(.horizontal, .xl)
                HStack(spacing: 0) {
                    VStack(alignment: .center, spacing: 10) {
                        Image(.icAppearanceDefault)
                            .clipShape(RoundedRectangle(cornerRadius: 16))
                            .overlay(RoundedRectangle(cornerRadius: 16).stroke(Color.colorInteractiveToneHighlight, lineWidth: appSetting.appearance == .system ? 2 : 0))
                        HStack(spacing: colorScheme == .light && appSetting.appearance != .system ? 4 : 6) {
                            if colorScheme == .light && appSetting.appearance != .system {
                                Image(.icRadioUncheckRadius)
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width: 22, height: 22)
                                    .padding(.top, 2)
                            } else {
                                Image(appSetting.appearance == .system ? .icRadioCheck : .icRadioUncheck)
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width: 16, height: 16)
                            }
                            Text("Default")
                                .font(.paragraphSmall)
                                .foregroundStyle(.colorBaseTent)
                        }
                        .frame(height: 20)
                        .padding(.leading, colorScheme == .light && appSetting.appearance != .system ? -4 : 0)
                    }
                    .frame(maxWidth: .infinity)
                    .contentShape(.rect)
                    .onTapGesture {
                        appSetting.applyAppearanceStyle(.system)
                    }
                    Spacer()
                    VStack(alignment: .center, spacing: 10) {
                        Image(.icAppearanceDark)
                            .clipShape(RoundedRectangle(cornerRadius: 16))
                            .overlay(RoundedRectangle(cornerRadius: 16).stroke(Color.colorInteractiveToneHighlight, lineWidth: appSetting.appearance == .dark ? 2 : 0))
                        HStack(spacing: colorScheme == .light && appSetting.appearance != .dark ? 4 : 6) {
                            if colorScheme == .light && appSetting.appearance != .dark {
                                Image(.icRadioUncheckRadius)
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width: 22, height: 22)
                                    .padding(.top, 2)
                            } else {
                                Image(appSetting.appearance == .dark ? .icRadioCheck : .icRadioUncheck)
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width: 16, height: 16)
                            }
                            Text("Dark")
                                .font(.paragraphSmall)
                                .foregroundStyle(.colorBaseTent)
                        }
                        .frame(height: 20)
                        .padding(.leading, colorScheme == .light && appSetting.appearance != .dark ? -4 : 0)
                    }
                    .frame(maxWidth: .infinity)
                    .contentShape(.rect)
                    .onTapGesture {
                        appSetting.applyAppearanceStyle(.dark)
                    }
                    Spacer()
                    VStack(alignment: .center, spacing: 10) {
                        Image(.icAppearanceLight)
                            .clipShape(RoundedRectangle(cornerRadius: 16))
                            .overlay(RoundedRectangle(cornerRadius: 16).stroke(Color.colorInteractiveToneHighlight, lineWidth: appSetting.appearance == .light ? 2 : 0))
                        HStack(spacing: colorScheme == .light && appSetting.appearance != .light ? 4 : 6) {
                            if colorScheme == .light && appSetting.appearance != .light {
                                Image(.icRadioUncheckRadius)
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width: 22, height: 22)
                                    .padding(.top, 2)
                            } else {
                                Image(appSetting.appearance == .light ? .icRadioCheck : .icRadioUncheck)
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width: 16, height: 16)
                            }

                            Text("Light")
                                .font(.paragraphSmall)
                                .foregroundStyle(.colorBaseTent)
                        }
                        .frame(height: 20)
                        .padding(.leading, colorScheme == .light && appSetting.appearance != .light ? -4 : 0)
                    }
                    .frame(maxWidth: .infinity)
                    .contentShape(.rect)
                    .onTapGesture {
                        appSetting.applyAppearanceStyle(.light)
                    }
                }
                .padding(.horizontal, .xl)
                Text("When you set the appearance to default, theme app will be depended on device settings.")
                    .font(.paragraphXSmall)
                    .foregroundStyle(.colorInteractiveTentPrimarySub)
                    .multilineTextAlignment(.center)
                    .padding(.vertical, .xl)
                    .padding(.horizontal, .xl)
            }
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
        AppearanceView()
            .environmentObject(AppSetting.shared)
        Spacer()
    }
    .background(Color.black)
}
