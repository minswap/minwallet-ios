import SwiftUI
import FlowStacks


struct RestoreWalletImportFileView: View {
    @EnvironmentObject
    private var navigator: FlowNavigator<MainCoordinatorViewModel.Screen>
    @EnvironmentObject
    private var hudState: HUDState
    @EnvironmentObject
    private var bannerState: BannerState
    @State
    private var isShowing = false
    @State
    private var fileURL: URL?
    @State
    private var fileSize: String = "0KB"
    @State
    private var fileContent: String = ""
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("Import file")
                .font(.titleH5)
                .foregroundStyle(.colorBaseTent)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.top, .lg)
                .padding(.bottom, .xl)
                .padding(.horizontal, .xl)
            
            if let fileURL = fileURL {
                HStack(spacing: 8) {
                    Image(.icSelectFileImport)
                        .resizable()
                        .frame(width: 44, height: 44)
                    VStack(alignment: .leading, spacing: 4) {
                        Text(fileURL.lastPathComponent)
                            .font(.labelSmallSecondary)
                            .foregroundStyle(.colorBaseTent)
                            .lineLimit(1)
                        Text(fileSize)
                            .font(.paragraphSmall)
                            .foregroundStyle(.colorInteractiveTentPrimarySub)
                    }
                    Spacer()
                    Image(.icClose)
                        .resizable()
                        .frame(width: 20, height: 20)
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(.colorSurfacePrimarySub)
                .overlay(RoundedRectangle(cornerRadius: 16).stroke(.colorBorderSecondSub, lineWidth: 1))
                .padding(.horizontal, .xl)
                .padding(.top, .md)
                .contentShape(.rect)
                .onTapGesture {
                    withAnimation {
                        self.fileURL = nil
                        self.fileSize = "0KB"
                    }
                }
            } else {
                VStack(alignment: .center, spacing: 8) {
                    Image(.icSelectFileImport)
                        .resizable()
                        .frame(width: 96, height: 96)
                    Text("Import Minwallet.json file")
                        .font(.labelSmallSecondary)
                        .foregroundStyle(.colorBaseTent)
                }
                .frame(maxWidth: .infinity)
                .padding()
                .overlay {
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(style: StrokeStyle(lineWidth: 1, dash: [8, 5]))
                        .foregroundColor(.colorBorderSecondSub)
                }
                .padding(.horizontal, .xl)
                .padding(.top, .md)
                .contentShape(.rect)
                .onTapGesture {
                    isShowing = true
                }
            }
            Spacer()
            let combinedBinding = Binding<Bool>(
                get: { !fileContent.isBlank },
                set: { _ in }
            )
            CustomButton(title: "Next", isEnable: combinedBinding) {
                guard !fileContent.isBlank else { return }
                navigator.push(.restoreWallet(.setupNickName(fileContent: fileContent, seedPhrase: [])))
            }
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
        .fileImporter(isPresented: $isShowing, allowedContentTypes: [.json]) { result in
            switch result {
            case let .success(url):
                withAnimation {
                    do {
                        self.fileURL = url
                        guard url.startAccessingSecurityScopedResource() else { return }
                        self.fileContent = try String(contentsOf: url, encoding: .utf8)
                    } catch {
                        bannerState.showBannerError(error.localizedDescription)
                    }
                    guard let attributes = try? FileManager.default.attributesOfItem(atPath: url.path),
                        let fileSize = attributes[.size] as? Int64
                    else {
                        self.fileSize = "0KB"
                        self.fileContent = ""
                        return
                    }
                    self.fileSize = self.formatFileSize(bytes: fileSize)
                }
            case let .failure(error):
                print(error)
            }
        }
    }
    
    private func formatFileSize(bytes: Int64) -> String {
        let units = ["bytes", "KB", "MB", "GB", "TB"]
        var value = Double(bytes)
        var index = 0
        
        while value >= 1024 && index < units.count - 1 {
            value /= 1024
            index += 1
        }
        
        return String(format: "%.0f%@", value, units[index])
    }
}

#Preview {
    RestoreWalletImportFileView()
}
