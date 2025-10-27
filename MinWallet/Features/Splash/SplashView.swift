import SwiftUI
import FlowStacks
import UIKit


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
