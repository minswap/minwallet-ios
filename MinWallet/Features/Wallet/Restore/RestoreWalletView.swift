import SwiftUI
import FlowStacks


struct RestoreWalletView: View {
    enum RestoreType {
        case seedPhrase
        case importJson
    }
    
    @EnvironmentObject
    var navigator: FlowNavigator<MainCoordinatorViewModel.Screen>
    
    @State
    private var restoreType: RestoreType = .seedPhrase
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("Restore wallet")
                .font(.titleH5)
                .foregroundStyle(.colorBaseTent)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.top, .lg)
                .padding(.bottom, .xl)
                .padding(.horizontal, .xl)
            Text("Select method to restore your wallet:")
                .font(.paragraphSmall)
                .foregroundStyle(.colorBaseTent)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.top, .lg)
                .padding(.bottom, .lg)
                .padding(.horizontal, .xl)
            HStack(alignment: .top, spacing: .xl) {
                VStack(alignment: .leading, spacing: 0) {
                    HStack(alignment: .top, spacing: .md) {
                        Image(.icRestoreSeedPhrase)
                            .resizable()
                            .renderingMode(.template)
                            .foregroundStyle(restoreType == .seedPhrase ? .colorInteractiveToneHighlight : .colorInteractiveTentPrimarySub)
                            .frame(width: 20, height: 20)
                            .padding(.top, 2)
                        Spacer()
                        if restoreType == .seedPhrase {
                            Image(.icChecked)
                        }
                    }
                    Text("Seedphrase")
                        .font(.titleH7)
                        .foregroundStyle(restoreType == .seedPhrase ? .colorInteractiveToneHighlight : .colorBaseTent)
                        .padding(.top, .xl)
                        .padding(.bottom, .xs)
                    Text("Restore using seed phrase")
                        .font(.paragraphSmall)
                        .foregroundStyle(restoreType == .seedPhrase ? .colorInteractiveToneHighlight : .colorInteractiveTentPrimarySub)
                    Spacer()
                }
                .padding(16)
                .frame(maxHeight: .infinity)
                .overlay(RoundedRectangle(cornerRadius: 16).stroke(restoreType == .seedPhrase ? .colorInteractiveToneHighlight : .colorBorderPrimaryTer, lineWidth: restoreType == .seedPhrase ? 3 : 2))
                .contentShape(.rect)
                .onTapGesture {
                    restoreType = .seedPhrase
                }
                VStack(alignment: .leading, spacing: 0) {
                    HStack(alignment: .top, spacing: .md) {
                        Image(.icImportJson)
                            .resizable()
                            .renderingMode(.template)
                            .foregroundStyle(restoreType == .importJson ? .colorInteractiveToneHighlight : .colorInteractiveTentPrimarySub)
                            .frame(width: 20, height: 20)
                            .padding(.top, 2)
                        Spacer()
                        if restoreType == .importJson {
                            Image(.icChecked)
                        }
                    }
                    Text("Import")
                        .font(.titleH7)
                        .foregroundStyle(restoreType == .importJson ? .colorInteractiveToneHighlight : .colorBaseTent)
                        .padding(.top, .xl)
                        .padding(.bottom, .xs)
                    Text("Import from existing wallet json file")
                        .font(.paragraphSmall)
                        .foregroundStyle(restoreType == .importJson ? .colorInteractiveToneHighlight : .colorInteractiveTentPrimarySub)
                    Spacer()
                }
                .padding(16)
                .frame(maxHeight: .infinity)
                .overlay(RoundedRectangle(cornerRadius: 16).stroke(restoreType == .importJson ? .colorInteractiveToneHighlight : .colorBorderPrimaryTer, lineWidth: restoreType == .importJson ? 3 : 2))
                .contentShape(.rect)
                .onTapGesture {
                    restoreType = .importJson
                }
            }
            .fixedSize(horizontal: false, vertical: true)
            .padding(.horizontal, .xl)
            .padding(.top, .lg)
            Spacer()
            CustomButton(title: "Restore") {
                switch restoreType {
                case .seedPhrase:
                    navigator.push(.restoreWallet(.seedPhrase))
                case .importJson:
                    navigator.push(.restoreWallet(.importFile))
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
    RestoreWalletView()
}
