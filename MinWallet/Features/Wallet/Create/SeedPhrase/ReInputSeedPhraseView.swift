import SwiftUI
import FlowStacks


struct ReInputSeedPhraseView: View {
    enum ScreenType {
        case createWallet(seedPhrase: [String])
        case restoreWallet
    }

    @EnvironmentObject
    private var navigator: FlowNavigator<MainCoordinatorViewModel.Screen>
    @EnvironmentObject
    private var appSetting: AppSetting
    @EnvironmentObject
    private var hudState: HUDState
    @FocusState
    private var isFocus: Bool
    @State
    private var inputSeedPhrase: String = ""
    @State
    var screenType: ScreenType

    private var isValidSeedPhase: Bool {
        guard !inputSeedPhrase.trimmingCharacters(in: .whitespacesAndNewlines).isBlank else { return false }
        return textWarning.toString().isBlank
    }

    private var textWarning: LocalizedStringKey {
        let inputSeedPhraseString = inputSeedPhrase.trimmingCharacters(in: .whitespacesAndNewlines)
        let inputSeedPhrase: [String] = inputSeedPhraseString.split(separator: " ").map { String($0) }
        let seedPhraseCount = inputSeedPhrase.count
        if seedPhraseCount == 0 { return "" }
        switch screenType {
        case let .createWallet(seedPhrase):

            if seedPhraseCount != 24 && seedPhraseCount != 15 && seedPhraseCount != 12 {
                return "Invalid seed phrase"
            }

            if inputSeedPhraseString.lowercased() != seedPhrase.joined(separator: " ").lowercased() {
                return "Invalid seed phrase"
            }

            if !inputSeedPhrase.allSatisfy({ appSetting.bip0039.contains($0.lowercased()) }) {
                return "Invalid seed phrase"
            }

            return ""

        case .restoreWallet:
            if seedPhraseCount != 24 && seedPhraseCount != 15 && seedPhraseCount != 12 {
                return "Invalid seed phrase"
            }

            if !inputSeedPhrase.allSatisfy({ appSetting.bip0039.contains($0) }) {
                return "Invalid seed phrase"
            }

            return ""
        }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("Re-input your seed phrase")
                .font(.titleH5)
                .foregroundStyle(.colorBaseTent)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.top, .lg)
                .padding(.bottom, .xl)
                .padding(.horizontal, .xl)
            SeedPhraseTextField(
                text: $inputSeedPhrase,
                typingColor: .colorBaseTent,
                completedColor: .colorInteractiveToneHighlight,
                onCommit: {
                    if inputSeedPhrase.last != " " {
                        inputSeedPhrase += " "
                    }
                }
            )
            .focused($isFocus)
            .padding(.horizontal, .xl)
            if !textWarning.toString().isEmpty {
                HStack(alignment: .center, spacing: 4) {
                    Image(.icWarning)
                        .fixSize(16)
                    Text(textWarning)
                        .font(.paragraphSmall)
                        .foregroundStyle(.colorInteractiveDangerTent)
                    Spacer()
                }
                .padding(.horizontal, .xl)
            }
            Spacer()
            HStack {
                Spacer()
                Button(
                    action: {
                        if let clipBoardText = UIPasteboard.general.string?.trimmingCharacters(in: .whitespacesAndNewlines) {
                            inputSeedPhrase = clipBoardText + " "
                        }
                    },
                    label: {
                        Text("Paste")
                            .font(.labelSmallSecondary)
                            .foregroundStyle(.colorInteractiveTentSecondaryDefault)
                    }
                )
                .buttonStyle(.plain)
                .padding(.horizontal, 20)
                .frame(height: 36)
                .background(.colorBaseBackground)
                .overlay(content: {
                    RoundedRectangle(cornerRadius: BorderRadius.full).stroke(.colorInteractiveTentSecondarySub, lineWidth: 1)
                })
            }
            .padding(.bottom, 34)
            .padding(.top, .xl)
            .padding(.horizontal, .xl)
            let enableNext = Binding<Bool>(
                get: { isValidSeedPhase },
                set: { newValue in }
            )
            CustomButton(title: "Next", isEnable: enableNext) {
                switch screenType {
                case let .createWallet(seedPhrase):
                    guard inputSeedPhrase.trimmingCharacters(in: .whitespacesAndNewlines) == seedPhrase.joined(separator: " ") else { return }
                    navigator.push(.createWallet(.setupNickName(seedPhrase: seedPhrase)))
                case .restoreWallet:
                    guard !inputSeedPhrase.trimmingCharacters(in: .whitespacesAndNewlines).isBlank else { return }

                    let seedPhrase = inputSeedPhrase.trimmingCharacters(in: .whitespacesAndNewlines)

                    guard createWallet(phrase: seedPhrase, password: MinWalletConstant.passDefaultForFaceID, networkEnv: MinWalletConstant.networkID, walletName: "MyMinWallet") != nil
                    else {
                        hudState.showMsg(msg: "Invalid seed phrase")
                        return
                    }

                    navigator.push(.restoreWallet(.setupNickName(fileContent: "", seedPhrase: seedPhrase.split(separator: " ").map({ String($0) }))))
                }
            }
            .frame(height: 56)
            .padding(.horizontal, .xl)
        }
        .modifier(
            BaseContentView(
                screenTitle: " ",
                actionLeft: {
                    navigator.pop()
                }))
    }
}

#Preview {
    ReInputSeedPhraseView(screenType: .restoreWallet)
}
