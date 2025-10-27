import SwiftUI
import FlowStacks
import Combine


struct SetupNickNameView: View {
    enum ScreenType {
        case createWallet(seedPhrase: [String])
        case restoreWallet(fileContent: String, seedPhrase: [String])
        case walletSetting
    }
    
    @EnvironmentObject
    private var navigator: FlowNavigator<MainCoordinatorViewModel.Screen>
    @EnvironmentObject
    private var userInfo: UserInfo
    @EnvironmentObject
    private var appSetting: AppSetting
    @FocusState
    private var isInputActive: Bool
    @State
    private var nickName: String = ""
    
    @State
    var screenType: ScreenType
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("Set up nickname")
                .font(.titleH5)
                .foregroundStyle(.colorBaseTent)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.top, .lg)
                .padding(.bottom, .xl)
                .padding(.horizontal, .xl)
            TextField("Give your wallet a nickname ...", text: $nickName)
                .font(.labelMediumSecondary)
                .foregroundStyle(.colorBaseTent)
                .focused($isInputActive)
                .padding(.horizontal, .xl)
                .keyboardType(.asciiCapable)
                .submitLabel(.done)
                .autocorrectionDisabled()
                .onReceive(Just(nickName)) { _ in
                    if nickName.count > 40 {
                        nickName = String(nickName.prefix(40))
                    }
                }
            if !nickName.isEmpty && nickName.count < 3 {
                HStack(spacing: 4) {
                    Image(.icWarning)
                        .fixSize(16)
                    Text("A wallet name must be 3-40 characters")
                        .font(.paragraphSmall)
                        .foregroundStyle(.colorInteractiveDangerTent)
                    Spacer()
                }
                .padding(.top, .xl)
                .padding(.horizontal, .xl)
            }
            Spacer()
            let title: LocalizedStringKey = {
                switch screenType {
                case .createWallet,
                    .restoreWallet:
                    "Next"
                case .walletSetting:
                    "Change"
                }
            }()
            let combinedBinding = Binding<Bool>(
                get: { nickName.trimmingCharacters(in: .whitespacesAndNewlines).count >= 3 },
                set: { _ in }
            )
            HStack {
                Text("\(nickName.count)")
                    .font(.paragraphSmall)
                    .foregroundColor(.colorInteractiveToneHighlight) + Text(" / 40").font(.paragraphSmall).foregroundColor(.colorInteractiveTentPrimarySub)
            }
            .padding(.xl)
            CustomButton(title: title, isEnable: combinedBinding) {
                switch screenType {
                case let .createWallet(seedPhrase):
                    navigator.push(.createWallet(.biometricSetup(seedPhrase: seedPhrase, nickName: nickName.trimmingCharacters(in: .whitespacesAndNewlines))))
                case let .restoreWallet(fileContent, seedPhrase):
                    navigator.push(
                        .restoreWallet(
                            .biometricSetup(
                                fileContent: fileContent,
                                seedPhrase: seedPhrase,
                                nickName: nickName.trimmingCharacters(in: .whitespacesAndNewlines))))
                case .walletSetting:
                    guard let minWallet = userInfo.minWallet, !nickName.isBlank else { return }
                    guard let minWallet = changeWalletName(wallet: minWallet, password: appSetting.password, newWalletName: nickName.trimmingCharacters(in: .whitespacesAndNewlines)) else { return }
                    userInfo.saveWalletInfo(walletInfo: minWallet)
                    
                    navigator.pop()
                }
            }
            .frame(height: 56)
            .padding(.top, .xl)
            .padding(.horizontal, .xl)
        }
        .modifier(
            BaseContentView(
                screenTitle: " ",
                actionLeft: {
                    navigator.pop()
                })
        )
        .task {
            guard case .walletSetting = screenType else { return }
            nickName = userInfo.minWallet?.walletName ?? ""
        }
    }
}

#Preview {
    SetupNickNameView(screenType: .walletSetting)
        .environmentObject(UserInfo.shared)
}
