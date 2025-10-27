import SwiftUI
import CodeScanner
import FlowStacks
import AVFoundation


struct ScanQRView: View {
    @EnvironmentObject
    private var navigator: FlowNavigator<MainCoordinatorViewModel.Screen>
    @EnvironmentObject
    private var hud: HUDState
    @EnvironmentObject
    private var appSetting: AppSetting
    @State
    private var qrCode: String?
    @State
    private var isValidatingQR: Bool = false
    @State
    private var isPermissionDenied = false
    @State
    private var showAlert = false
    
    var body: some View {
        ZStack {
            if !isPermissionDenied {
                CodeScannerView(
                    codeTypes: [.qr],
                    scanMode: .continuous,
                    scanInterval: 3
                ) { response in
                    Task {
                        if case let .success(result) = response, !isValidatingQR {
                            qrCode = result.string
                            
                            guard let qrCode = qrCode else { return }
                            isValidatingQR = true
                            
                            var isValidAddress = false
                            if !qrCode.hasPrefix(MinWalletConstant.addressPrefix) {
                                isValidAddress = false
                            } else {
                                let suffixAddress = qrCode.trimmingPrefix(MinWalletConstant.addressPrefix)
                                if suffixAddress.count == 98 {
                                    isValidAddress = true
                                } else {
                                    isValidAddress = false
                                }
                            }
                            if !isValidAddress {
                                hud.showMsg(
                                    title: "Invalid QR code",
                                    msg: "Not a valid address. Make sure it's an address for current network and it is either a valid Shelley or Byron(legacy) address",
                                    okTitle: "Try again")
                            } else {
                                navigator.push(.sendToken(.selectToken(tokensSelected: [], screenType: .initSelectedToken, sourceScreenType: .scanQRCode(address: qrCode), onSelectToken: nil)))
                            }
                            isValidatingQR = false
                        }
                    }
                }
                .overlay(
                    QRScanOverlay()
                )
            }
            VStack {
                HStack(spacing: .lg) {
                    Image(isPermissionDenied ? .icBack : .icCloseScreen)
                        .resizable()
                        .frame(width: isPermissionDenied ? 20 : 40, height: isPermissionDenied ? 20 : 40)
                        .padding(isPermissionDenied ? .md : 0)
                        .background(RoundedRectangle(cornerRadius: BorderRadius.full).stroke(!isPermissionDenied ? .clear : .colorBorderPrimaryTer, lineWidth: 1))
                        .onTapGesture {
                            navigator.pop()
                        }
                    Text("Scan QR code")
                        .font(.labelMediumSecondary)
                        .foregroundColor(.colorInteractiveToneTent2)
                    Spacer()
                }
                .padding(.horizontal, .xl)
                .frame(height: 48)
                .padding(.top, appSetting.safeArea)
                if isPermissionDenied {
                    Spacer()
                    Text("Camera access is denied.\n Please allow camera access in Settings.")
                        .font(.paragraphSmall)
                        .multilineTextAlignment(.center)
                        .padding()
                    Text("Open Settings")
                        .font(.paragraphSemi)
                        .frame(height: 40)
                        .contentShape(.rect)
                        .onTapGesture {
                            MinWalletApp.openAppSettings()
                        }
                }
                Spacer()
                
                CustomButton(title: "Show my QR") {
                    navigator.push(.receiveToken(.qrCode))
                }
                .frame(height: 56)
                .padding(.horizontal, .xl)
                .padding(.bottom, UIApplication.safeArea.bottom)
                .safeAreaInset(edge: .bottom) {
                    Color.clear.frame(height: 0)
                }
            }
        }
        .onAppear {
            checkCameraPermission()
        }
        .alert(isPresented: $showAlert) {
            Alert(
                title: Text("Camera Permission Denied"),
                message: Text("Please grant camera access in Settings to use this feature."),
                dismissButton: .default(Text("OK"))
            )
        }
        .background(isPermissionDenied ? .colorBaseBackground : .clear)
        .ignoresSafeArea()
    }
    
    private func checkCameraPermission() {
        let cameraAuthorizationStatus = AVCaptureDevice.authorizationStatus(for: .video)
        
        switch cameraAuthorizationStatus {
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { granted in
                DispatchQueue.main.async {
                    if !granted {
                        self.isPermissionDenied = true
                        self.showAlert = true
                    }
                }
            }
        case .restricted, .denied:
            // Permission is denied or restricted
            isPermissionDenied = true
            showAlert = true
        case .authorized:
            // Permission is granted
            isPermissionDenied = false
        @unknown default:
            break
        }
    }
}

#Preview {
    ScanQRView()
}

private struct QRScanOverlay: View {
    var body: some View {
        GeometryReader { proxy in
            ZStack {
                VisualEffectBlurView()
                    .ignoresSafeArea()
                let width = proxy.size.width - 70
                RoundedRectangle(cornerRadius: 16)
                    .frame(width: width, height: width)
                    .blendMode(.destinationOut)
                    .overlay(
                        CornerShape()
                            .stroke(Color.colorInteractiveToneTent2, lineWidth: 4)
                            .padding(2)
                    )
            }
            .compositingGroup()
        }
    }
}

private struct CornerShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        
        let cornerLength: CGFloat = 35
        let cornerRadius: CGFloat = 16
        
        // Top-left corner
        path.move(to: CGPoint(x: rect.minX, y: rect.minY + cornerLength))
        path.addLine(to: CGPoint(x: rect.minX, y: rect.minY + cornerRadius))
        path.addQuadCurve(
            to: CGPoint(x: rect.minX + cornerRadius, y: rect.minY),
            control: CGPoint(x: rect.minX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.minX + cornerLength, y: rect.minY))
        
        // Top-right corner
        path.move(to: CGPoint(x: rect.maxX - cornerLength, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.maxX - cornerRadius, y: rect.minY))
        path.addQuadCurve(
            to: CGPoint(x: rect.maxX, y: rect.minY + cornerRadius),
            control: CGPoint(x: rect.maxX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.minY + cornerLength))
        
        // Bottom-right corner
        path.move(to: CGPoint(x: rect.maxX, y: rect.maxY - cornerLength))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY - cornerRadius))
        path.addQuadCurve(
            to: CGPoint(x: rect.maxX - cornerRadius, y: rect.maxY),
            control: CGPoint(x: rect.maxX, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.maxX - cornerLength, y: rect.maxY))
        
        // Bottom-left corner
        path.move(to: CGPoint(x: rect.minX + cornerLength, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.minX + cornerRadius, y: rect.maxY))
        path.addQuadCurve(
            to: CGPoint(x: rect.minX, y: rect.maxY - cornerRadius),
            control: CGPoint(x: rect.minX, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.minX, y: rect.maxY - cornerLength))
        
        return path
    }
}
