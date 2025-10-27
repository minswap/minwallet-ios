import SwiftUI
import WebKit
import Combine

class WebViewModel: ObservableObject {
    @Published var progress: Double = 0.0
    private var cancellable: AnyCancellable?
    
    func observeWebView(_ webView: WKWebView) {
        cancellable = webView.publisher(for: \.estimatedProgress)
            .debounce(for: .milliseconds(200), scheduler: DispatchQueue.main)
            .receive(on: RunLoop.main)
            .sink { [weak self] progress in
                self?.progress = progress
            }
    }
}

struct WebView: UIViewRepresentable {
    let urlString: String
    @ObservedObject var viewModel: WebViewModel
    
    func makeUIView(context: Context) -> WKWebView {
        let webView = WKWebView()
        viewModel.observeWebView(webView)
        
        if let url = URL(string: urlString) {
            let request = URLRequest(url: url)
            webView.load(request)
        }
        
        return webView
    }
    
    func updateUIView(_ webView: WKWebView, context: Context) {}
}

struct PreloadWebViewPolicy: UIViewRepresentable {
    @ObservedObject var preloadWebVM: PreloadWebViewModel
    
    func makeUIView(context: Context) -> WKWebView {
        preloadWebVM.webView.scrollView.contentOffset = .init(x: 0, y: 0)
        return preloadWebVM.webView
    }
    
    func updateUIView(_ webView: WKWebView, context: Context) {}
}


class PreloadWebViewModel: ObservableObject {
    @Published var progress: Double = 0.0
    private var cancellables: Set<AnyCancellable> = []
    
    let webView = WKWebView()
    
    init() {
        webView.publisher(for: \.estimatedProgress)
            .debounce(for: .milliseconds(200), scheduler: DispatchQueue.main)
            .receive(on: RunLoop.main)
            .sink { [weak self] progress in
                self?.progress = progress
            }
            .store(in: &cancellables)
    }
    
    func preloadContent(urlString: String) {
        guard let url = URL(string: urlString) else { return }
        let request = URLRequest(url: url)
        webView.load(request)
    }
}
