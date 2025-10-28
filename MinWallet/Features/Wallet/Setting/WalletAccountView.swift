import SwiftUI
import FlowStacks


struct WalletAccountView: View {
    @EnvironmentObject
    private var navigator: FlowNavigator<MainCoordinatorViewModel.Screen>
    @EnvironmentObject
    private var userInfo: UserInfo
    @EnvironmentObject
    private var appSetting: AppSetting
    @State
    private var isVerified: Bool = true
    @StateObject
    private var tokenManager: TokenManager = TokenManager.shared
    @State
    private var showEditNickName: Bool = false
    @State
    private var showDisconnectWallet: Bool = false
    @State
    private var isCopyAddress: Bool = false
    @Environment(\.colorScheme)
    private var colorScheme: ColorScheme

    var body: some View {
        VStack(spacing: 0) {
            ZStack {
                Image(.icAvatarDefault)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 96, height: 96)
                    .clipShape(Circle())

                if isVerified {
                    Image(.icSubAvatar)
                        .resizable()
                        .frame(width: 24, height: 24)
                        .position(x: 84, y: 84)
                }
            }
            .frame(width: 96, height: 96)
            .padding(.vertical, .lg)
            VStack(alignment: .center, spacing: 4) {
                HStack(spacing: 4) {
                    if !userInfo.adaHandleName.isBlank {
                        Image(.icAdahandle)
                            .resizable()
                            .frame(width: 16, height: 16)
                        Text(userInfo.adaHandleName)
                            .font(.titleH7)
                            .foregroundStyle(.colorInteractiveToneHighlight)
                            .lineLimit(1)
                            .minimumScaleFactor(0.1)
                            .padding(.trailing, 4)
                        Text(userInfo.walletName)
                            .font(.paragraphXMediumSmall)
                            .foregroundStyle(.colorInteractiveToneHighlight)
                            .padding(.horizontal, .lg)
                            .padding(.vertical, .xs)
                            .background(
                                RoundedRectangle(cornerRadius: BorderRadius.full).fill(.colorSurfaceHighlightDefault)
                            )
                            .frame(height: 20)
                            .lineLimit(1)
                            .minimumScaleFactor(0.1)
                    } else {
                        Text(userInfo.walletName)
                            .font(.titleH7)
                            .foregroundStyle(.colorBaseTent)
                            .lineLimit(1)
                            .minimumScaleFactor(0.1)
                    }
                }
                HStack(spacing: 4) {
                    Spacer()
                    Text(userInfo.minWallet?.address.shortenAddress)
                        .font(.paragraphXSmall)
                        .foregroundStyle(isCopyAddress ? .colorBaseSuccess : .colorInteractiveTentPrimarySub)
                    if isCopyAddress {
                        Image(.icCheckMark)
                            .resizable()
                            .renderingMode(.template)
                            .foregroundStyle(.colorBaseSuccess)
                            .frame(width: 16, height: 16)
                    } else {
                        Image(.icCopy)
                            .resizable()
                            .scaledToFill()
                            .frame(width: 16, height: 16)
                    }
                    Spacer()
                }
                .contentShape(.rect)
                .onTapGesture {
                    UIPasteboard.general.string = userInfo.minWallet?.address
                    withAnimation {
                        isCopyAddress = true
                    }
                    DispatchQueue.main.asyncAfter(
                        deadline: .now() + .seconds(2),
                        execute: {
                            withAnimation {
                                self.isCopyAddress = false
                            }
                        })
                }
            }
            .padding(.horizontal, .xl)
            /*
            VStack(spacing: 4) {
                HStack(spacing: .md) {
                    Text("Account #0")
                        .font(.paragraphSemi)
                        .foregroundStyle(.colorInteractiveToneHighlight)
                    Spacer()
                    Text("Total Funds")
                        .font(.paragraphXSmall)
                        .foregroundStyle(.colorInteractiveToneWarning)
                }
                HStack(spacing: .md) {
                    Text("Active")
                        .font(.paragraphXSmall)
                        .foregroundStyle(.colorInteractiveToneWarning)
                    Spacer()
                    let prefix: String = appSetting.currency == Currency.usd.rawValue ? Currency.usd.prefix : ""
                    let suffix: String = appSetting.currency == Currency.ada.rawValue ? " \(Currency.ada.prefix)" : ""
                    let adaValue: Double = appSetting.currency == Currency.ada.rawValue ? tokenManager.adaValue : (tokenManager.adaValue * appSetting.currencyInADA)
                    Text(prefix + adaValue.formatSNumber(maximumFractionDigits: 2) + suffix)
                        .font(.paragraphSemi)
                        .foregroundStyle(.colorInteractiveTentPrimarySub)
                }
            }
            .padding(.xl)
            .overlay(RoundedRectangle(cornerRadius: 16).stroke(.colorBorderPrimarySub, lineWidth: 1))
            .contentShape(.rect)
            .padding(.horizontal, .xl)
            .padding(.top, .lg)
             */
            CustomButton(
                title: "Edit nickname",
                variant: .secondary,
                action: {
                    //navigator.push(.walletSetting(.editNickName))
                    $showEditNickName.showSheet()
                }
            )
            .frame(height: 44)
            .padding(.xl)
            /*
            HStack(spacing: .lg) {
                Image(.icLockPassword)
                    .resizable()
                    .frame(width: 20, height: 20)
                Text("Change password")
                    .font(.paragraphSemi)
                    .foregroundStyle(.colorBaseTent)
                Spacer()
                Image(.icNext)
                    .frame(width: 20, height: 20)
            }
            .frame(height: 52)
            .padding(.horizontal, .xl)
            .contentShape(.rect)
            .onTapGesture {
                navigator.push(.walletSetting(.changePassword))
            }
             */
            Spacer()
            CustomButton(
                title: "Disconnect",
                variant: .other(textColor: .colorBaseTent, backgroundColor: .colorInteractiveDangerDefault, borderColor: .clear, textColorDisable: nil, backgroundColorDisable: nil),
                action: {
                    $showDisconnectWallet.showSheet()
                }
            )
            .frame(height: 56)
            .padding(.horizontal, .xl)
        }
        .modifier(
            BaseContentView(
                screenTitle: " ",
                actionLeft: {
                    navigator.pop()
                })
        )
        .presentSheet(isPresented: $showEditNickName) {
            EditNickNameView()
        }
        .presentSheet(isPresented: $showDisconnectWallet) {
            DisconnectWalletView()
        }
    }
}

#Preview {
    WalletAccountView()
        .environmentObject(UserInfo.shared)
        .environmentObject(AppSetting.shared)
}
