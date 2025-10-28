import SwiftUI

struct LanguageView: View {
    @EnvironmentObject
    private var appSetting: AppSetting
    @Environment(\.partialSheetDismiss)
    private var onDismiss

    var body: some View {
        VStack(spacing: 0) {
            Text("Language")
                .font(.titleH5)
                .frame(maxWidth: .infinity, alignment: .leading)
                .frame(height: 60)
                .padding(.horizontal, .xl)
            ScrollView {
                VStack {
                    ForEach(Language.allCases) { language in
                        HStack(spacing: 16) {
                            Text(language.title)
                                .font(.labelSmallSecondary)
                                .foregroundStyle(language.rawValue == appSetting.language ? .colorInteractiveToneHighlight : .colorBaseTent)
                            Spacer()
                            Image(.icChecked)
                                .opacity(language.rawValue == appSetting.language ? 1 : 0)
                        }
                        .frame(height: 52)
                        .padding(.horizontal, .xl)
                        .contentShape(.rect)
                        .onTapGesture {
                            appSetting.language = language.rawValue
                            onDismiss?()
                        }
                    }
                }
            }
        }
        .frame(height: (UIScreen.current?.bounds.height ?? 0) * 0.8)
        .presentSheetModifier()
    }
}

#Preview {
    VStack {
        LanguageView()
            .environmentObject(AppSetting.shared)
    }
}
