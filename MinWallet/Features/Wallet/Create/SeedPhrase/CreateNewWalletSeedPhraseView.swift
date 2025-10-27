import SwiftUI
import FlowStacks


struct CreateNewWalletSeedPhraseView: View {
    @EnvironmentObject
    private var navigator: FlowNavigator<MainCoordinatorViewModel.Screen>
    @State
    private var copied: Bool = false
    @State
    private var isRevealPhrase: Bool = false
    @State
    private var seedPhrase: [String] = []
    @State
    private var isConfirm: Bool = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("Create new wallet")
                .font(.titleH5)
                .foregroundStyle(.colorBaseTent)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.top, .lg)
                .padding(.bottom, .xl)
                .padding(.horizontal, .xl)
            SeedPhraseContentView(isRevealPhrase: $isRevealPhrase, seedPhrase: $seedPhrase)
            Spacer()
            if isRevealPhrase {
                SeedPhraseCopyView(copied: $copied, seedPhrase: $seedPhrase, isConfirm: $isConfirm)
                    .padding(.horizontal, .xl)
                    .padding(.bottom, UIApplication.safeArea.bottom > 0 ? UIApplication.safeArea.bottom : .xl)
            } else {
                SeedPhraseRevealView()
                    .frame(maxWidth: .infinity)
                    .padding(.horizontal, .xl)
                    .padding(.bottom, UIApplication.safeArea.bottom > 0 ? UIApplication.safeArea.bottom : .md)
                    .background(content: {
                        PartialRoundedBorder(cornerRadius: 24, lineWidth: 1)
                            .stroke(Color.colorBorderPrimarySub, lineWidth: 1)
                        
                    })
                    .contentShape(.rect)
                    .onTapGesture {
                        withAnimation {
                            isRevealPhrase = true
                        }
                    }
            }
        }
        .modifier(
            BaseContentView(
                screenTitle: " ",
                actionLeft: {
                    navigator.pop()
                },
                ignoreSafeArea: true)
        )
        .task {
            guard seedPhrase.isEmpty else { return }
            seedPhrase = genPhrase(wordCount: 24)?.split(separator: " ").map({ String($0) }) ?? []
        }
    }
}

#Preview {
    CreateNewWalletSeedPhraseView()
}

private struct SeedPhraseRevealView: View {
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Image(.icReveal)
                .resizable()
                .frame(width: 60, height: 60)
                .padding(.top, 24)
                .padding(.bottom, .xl)
            Text("Tap to reveal seed phrase")
                .font(.titleH7)
                .foregroundStyle(.colorInteractiveToneHighlight)
                .padding(.bottom, .md)
                .frame(maxWidth: .infinity, alignment: .leading)
            Text("Make sure no one is looking at your screen")
                .font(.paragraphSmall)
                .foregroundStyle(.colorInteractiveTentPrimarySub)
                .padding(.bottom, .xl)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
}


private struct SeedPhraseCopyView: View {
    @EnvironmentObject
    private var navigator: FlowNavigator<MainCoordinatorViewModel.Screen>
    @Binding var copied: Bool
    @Binding var seedPhrase: [String]
    @Binding var isConfirm: Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(alignment: .top, spacing: 8) {
                Image(isConfirm ? .icSquareCheckBox : .icSquareUncheckBox)
                    .resizable()
                    .frame(width: 20, height: 20)
                Text("I have written the seed phrase and stored it in a secured place.")
                    .font(.paragraphSmall)
                    .foregroundStyle(.colorInteractiveTentPrimarySub)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            .contentShape(.rect)
            .onTapGesture {
                isConfirm.toggle()
            }
            HStack(spacing: .xl) {
                CustomButton(
                    title: copied ? "Copied" : "Copy",
                    variant: .secondary,
                    iconRight: copied ? .icCheckMark : .icCopySeedPhrase
                ) {
                    copied = true
                    UIPasteboard.general.string = seedPhrase.joined(separator: " ")
                    DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(1)) {
                        withAnimation {
                            copied = false
                        }
                    }
                }
                .frame(height: 56)
                
                CustomButton(
                    title: "Next", isEnable: $isConfirm,
                    action: {
                        navigator.push(.createWallet(.reInputSeedPhrase(seedPhrase: seedPhrase)))
                    }
                )
                .frame(height: 56)
            }
        }
    }
}


private struct SeedPhraseContentView: View {
    @Binding
    var isRevealPhrase: Bool
    @Binding
    var seedPhrase: [String]
    
    private let columns = [
        GridItem(.flexible()),
        GridItem(.flexible()),
    ]
    
    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                Text("Please write down your 24 words seed phrase and store it in a secured place.")
                    .font(.paragraphSmall)
                    .foregroundStyle(.colorBaseTent)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, .xl)
                    .padding(.top, .lg)
                    .padding(.bottom, ._3xl)
                LazyVGrid(columns: columns, spacing: 0) {
                    ForEach(0..<seedPhrase.count, id: \.self) { index in
                        if let seedPhrase = seedPhrase[gk_safeIndex: index] {
                            HStack() {
                                Text(String(index + 1))
                                    .font(.paragraphSmall)
                                    .foregroundStyle(.colorInteractiveTentPrimaryDisable)
                                    .frame(width: 20, alignment: .leading)
                                Text(seedPhrase)
                                    .font(.paragraphSmall)
                                    .foregroundStyle(.colorBaseTent)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                if index % 2 == 0 {
                                    Color.colorBorderPrimaryTer.frame(width: 1)
                                        .padding(.trailing, 4)
                                }
                            }
                            .frame(height: 32)
                        }
                    }
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 14)
                .overlay(content: {
                    ZStack {
                        if isRevealPhrase {
                            HStack {
                                Spacer()
                                Button(
                                    action: {
                                        withAnimation {
                                            isRevealPhrase = false
                                        }
                                    },
                                    label: {
                                        Text("Hide")
                                            .font(.labelSmallSecondary)
                                            .foregroundStyle(.colorInteractiveTentSecondaryDefault)
                                    }
                                )
                                .buttonStyle(.plain)
                                .frame(height: 28)
                                .padding(.horizontal, .lg)
                                .background(.colorBaseBackground)
                                .overlay(content: {
                                    RoundedRectangle(cornerRadius: BorderRadius.full).stroke(.colorInteractiveTentPrimarySub, lineWidth: 1)
                                })
                                .offset(x: -20, y: -14)
                            }
                            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topTrailing)
                            .zIndex(999)
                            RoundedRectangle(cornerRadius: 20).stroke(.colorBorderPrimarySub, lineWidth: 1)
                        } else {
                            Image(.icHiddenSeedPhrase)
                                .resizable()
                                .clipped()
                        }
                    }
                })
                .padding(.horizontal, .xl)
                .padding(.bottom, .xl)
            }
        }
    }
}
