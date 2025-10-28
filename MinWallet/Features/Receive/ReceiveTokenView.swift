import SwiftUI
import FlowStacks


struct ReceiveTokenView: View {
    enum ScreenType {
        case home
        case qrCode
    }

    @EnvironmentObject
    private var navigator: FlowNavigator<MainCoordinatorViewModel.Screen>
    @EnvironmentObject
    private var userInfo: UserInfo
    @EnvironmentObject
    private var appSetting: AppSetting
    @State
    private var qrImage: UIImage?
    @State
    private var copied: Bool = false
    @State
    private var showShareSheet = false
    @State
    var screenType: ScreenType = .home

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text(screenType == .home ? "Receive" : "My QR")
                .font(.titleH5)
                .foregroundStyle(.colorBaseTent)
                .frame(maxWidth: .infinity, minHeight: 60, alignment: .leading)
                .padding(.horizontal, .xl)
            Text("Share this wallet address to receive payments.")
                .font(.paragraphSmall)
                .foregroundStyle(.colorInteractiveTentPrimarySub)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.top, .lg)
                .padding(.horizontal, .xl)
            VStack(spacing: 8) {
                Image(uiImage: qrImage ?? UIImage())
                    .resizable()
                    .frame(width: 180, height: 180)
                Text(userInfo.minWallet?.address)
                    .font(.paragraphSmall)
                    .lineSpacing(2)
                    .foregroundStyle(.colorBaseTent)
                    .multilineTextAlignment(.center)
                    .padding(.top, .md)
            }
            .padding(.xl)
            .padding(.bottom, .xl)
            .overlay(RoundedRectangle(cornerRadius: .xl).stroke(.colorBorderPrimaryDefault, lineWidth: 1))
            .padding(.horizontal, .xl)
            .padding(.top, ._3xl)
            Spacer()
            if screenType == .home {
                HStack(spacing: .xl) {
                    CustomButton(title: "Share", variant: .secondary) {
                        showShareSheet = true
                    }
                    .frame(height: 44)
                    CustomButton(
                        title: copied ? "Copied" : "Copy",
                        variant: .secondary,
                        iconRight: copied ? .icCheckMark : nil
                    ) {
                        withAnimation {
                            copied = true
                        }
                        UIPasteboard.general.string = userInfo.minWallet?.address
                        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(1)) {
                            withAnimation {
                                copied = false
                            }
                        }
                    }
                    .frame(height: 44)
                }
                .padding(.horizontal, .xl)
            } else {
                CustomButton(title: "Scan QR") {
                    navigator.pop()
                }
                .frame(height: 56)
                .padding(.horizontal, .xl)
            }
        }
        .modifier(
            BaseContentView(
                screenTitle: " ",
                actionLeft: {
                    switch screenType {
                    case .home:
                        navigator.pop()
                    case .qrCode:
                        if appSetting.rootScreen != .home {
                            appSetting.rootScreen = .home
                        }
                        navigator.popToRoot()
                    }
                })
        )
        .task {
            guard qrImage == nil else { return }
            qrImage = userInfo.minWallet?.address.generateQRCode(centerImage: UIImage(resource: .icLogoQr), size: .init(width: 200, height: 200), centerBackgroundColor: .white)
        }
        .sheet(isPresented: $showShareSheet) {
            if let qrImage = qrImage {
                ShareSheet(items: [qrImage])
            }
        }
    }
}

private struct ShareSheet: UIViewControllerRepresentable {
    var items: [Any]
    var excludedActivityTypes: [UIActivity.ActivityType]? = nil

    func makeUIViewController(context: Context) -> UIActivityViewController {
        let controller = UIActivityViewController(activityItems: items, applicationActivities: nil)
        controller.excludedActivityTypes = excludedActivityTypes
        return controller
    }

    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}

#Preview {
    ReceiveTokenView()
        .environmentObject(UserInfo.shared)
}
