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
    @State private var lock: Bool = false
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
            if lock || showJBWarning || !biometryAvailable {
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
                lock = newPhase != .active
                if newPhase == .active {
                    let result = JailbreakDetector.scan()
                    let showJBWarning = result.suspicionScore != 0
                    
                    self.showJBWarning = showJBWarning
                    
                    guard !showJBWarning else { return }
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
