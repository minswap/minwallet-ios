import SwiftUI
import FlowStacks
import LocalAuthentication


struct SplashView: View {
    @State private var scale = 0.7
    @State private var isActive: Bool = false
    
    @EnvironmentObject
    private var appSetting: AppSetting
    
    var body: some View {
        GeometryReader { geo in
            ZStack {
                if !isActive {
                    Color.colorBaseSecondNoDarkMode
                        .ignoresSafeArea(.all)
                    VStack {
                        Image(.icSplash).resizable().frame(width: 140, height: 140)
                    }
                    .scaleEffect(scale)
                    .onAppear {
                        withAnimation(.easeIn(duration: 0.7)) {
                            self.scale = 0.9
                        }
                    }
                } else {
                    switch appSetting.rootScreen {
                    case .home:
                        HomeView()
                    case .policy:
                        PolicyConfirmView()
                    case .gettingStarted:
                        GettingStartedView()
                    default:
                        EmptyView()
                    }
                }
            }
            .onAppear(perform: {
                appSetting.safeArea = UIApplication.safeArea.top
            })
        }
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                withAnimation {
                    self.isActive = true
                }
            }
        }
    }
}

#Preview {
    SplashView()
        .environmentObject(AppSetting.shared)
        .environmentObject(HUDState())
        .environmentObject(BannerState())
}


struct LockGateView<Content: View>: View {
    @State private var showJBWarning: Bool = false
    @State private var biometryAvailable: Bool = true
    @State private var showSuccess = false

    @EnvironmentObject
    private var appSetting: AppSetting
    @EnvironmentObject
    private var bannerState: BannerState
    @Environment(\.scenePhase)
    private var scenePhase
    
    let content: () -> Content
    
    var body: some View {
        ZStack {
            content()
            if showJBWarning || !biometryAvailable {
                VisualEffectBlurView()
                    .edgesIgnoringSafeArea(.all)
            }
            
            if showJBWarning {
                VStack(spacing: .xl) {
                    Spacer()
                    Text("This device appears compromised. Sensitive actions are disabled.")
                        .font(.labelMediumSecondary)
                        .foregroundStyle(.black)
                        .padding()
                    Spacer()
                }
            } else if !biometryAvailable {
                VStack(spacing: .xl) {
                    Spacer()
                    Text("Biometry is not available on this device.")
                        .font(.caption)
                        .foregroundStyle(.black)
                    Button("Open settings") {
                        if let url = URL(string: UIApplication.openSettingsURLString) {
                            UIApplication.shared.open(url)
                        }
                    }
                    Spacer()
                }
            }
        }
        .onChange(of: scenePhase) { newPhase in
            withAnimation {
                if newPhase == .active { 
                    guard appSetting.isLogin else { return }
                    let ctxBio = LAContext()
                    var err: NSError?
                    let canBio = ctxBio.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &err)
                    let biometryType = ctxBio.biometryType
                    let biometryAvailable = canBio && biometryType != .none
                    
                    self.biometryAvailable = biometryAvailable
                }
            }
        }
        .onAppear(perform: {
            if UIDevice.current.isJailBroken {
                fatalError("This device appears compromised. Sensitive actions are disabled.")
            }
            self.showJBWarning = UIDevice.current.isJailBroken
        })
        .showSystemAlert(
            $appSetting.showBiometryChanged,
            title: "Security Warning",
            messageString: "You just changed Face ID or Touch ID.\nPlease reinstall to continue using the app safely.",
            okTitle: "Reinstall",
            cancelTitle: "Cancel",
            onOK: {
                Task {
                    do {
                        _ = try await BiometricAuthentication.resetupBiometric()
                        showSuccess = true
                    } catch {
                        await BiometricAuthentication.deleteBiometric()
                        bannerState.showBannerError(error)
                    }
                }
            },
            onCancel: { })
        .showSystemAlert(
            $appSetting.openSettingForSetupFaceId,
            title: "Notice",
            message: $appSetting.messageForSetting,
            okTitle: "Open Settings",
            cancelTitle: "Cancel",
            onOK: {
                if let url = URL(string: UIApplication.openSettingsURLString) {
                    UIApplication.shared.open(url)
                }
            },
            onCancel: { })
        .showSystemAlert(
            $showSuccess,
            title: "Success",
            messageString: "Face ID/Touch ID setup successful!",
            okTitle: "OK")
    }
}


struct SensitiveView<Content: View>: View {
    var content: Content
    
    init(@ViewBuilder content: @escaping () -> Content) {
        self.content = content()
    }
    
    @State
    private var hostingController: UIHostingController<Content>?
    
    var body: some View {
        _ScreenshotPreventHelper(hostingController: $hostingController)
            .overlay {
                GeometryReader {
                    let size = $0.size
                    Color.clear.preference(key: SizeKey.self, value: size)
                        .onPreferenceChange(SizeKey.self, perform: { value in
                            if value != .zero {
                                if hostingController == nil {
                                    hostingController = UIHostingController(rootView: content)
                                    hostingController?.view.backgroundColor = .clear
                                    hostingController?.view.tag = 1009
                                }
                                hostingController?.view.frame = .init(origin: .zero, size: value)
                            }
                        })
                }
            }
    }
}

fileprivate struct _ScreenshotPreventHelper<Content: View>: UIViewRepresentable {
    @Binding var hostingController: UIHostingController<Content>?
    
    func makeUIView(context: Context) -> some UIView {
        let secureTextField = UITextField()
        secureTextField.isSecureTextEntry = true
        
        if let textLayoutView = secureTextField.subviews.first {
            return textLayoutView
        }
        return UIView()
    }
    
    func updateUIView(_ uiView: UIViewType, context: Context) {
        if let hostingController, !uiView.subviews.contains(where: { $0.tag == 1009 }) {
            uiView.addSubview(hostingController.view)
        }
    }
}
