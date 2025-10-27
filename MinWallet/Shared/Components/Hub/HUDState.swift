import SwiftUI


@MainActor
class HUDState: ObservableObject {
    @Published
    private(set) var msg: String = ""
    @Published
    private(set) var title: LocalizedStringKey = ""
    @Published
    private(set) var okTitle: LocalizedStringKey = ""
    @Published
    var isPresented: Bool = false
    @Published
    var isShowLoading: Bool = false
    
    var onAction: (() -> Void)?
    
    init() {}
    
    func showMsg(
        title: LocalizedStringKey = "Notice",
        msg: String,
        okTitle: LocalizedStringKey = "Got it",
        onAction: (() -> Void)? = nil
    ) {
        self.msg = msg
        self.title = title
        self.okTitle = okTitle
        self.onAction = onAction
        self.isPresented = true
    }
    
    func showLoading(_ isShow: Bool) {
        withAnimation {
            isShowLoading = isShow
        }
    }
}
