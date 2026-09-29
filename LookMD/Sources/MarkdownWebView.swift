import SwiftUI
import WebKit

struct MarkdownWebView: NSViewRepresentable {
    let markdown: String
    var baseURL: URL? = nil
    var onWebViewReady: ((WKWebView) -> Void)? = nil

    func makeNSView(context: Context) -> WKWebView {
        let webView = WKWebView(frame: .zero)
        webView.setValue(false, forKey: "drawsBackground")
        load(into: webView)
        onWebViewReady?(webView)
        return webView
    }

    func updateNSView(_ webView: WKWebView, context: Context) {
        load(into: webView)
    }

    private func load(into webView: WKWebView) {
        guard let html = try? MarkdownHTMLBuilder.buildHTML(markdown: markdown, bundle: .main, baseURL: baseURL) else {
            webView.loadHTMLString("<p>Unable to render document.</p>", baseURL: nil)
            return
        }
        webView.loadHTMLString(html, baseURL: baseURL)
    }
}
