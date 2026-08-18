import SwiftUI
import WebKit
import os.log

private let logger = Logger(subsystem: "com.musikutiv.lookmd", category: "webview")

struct MarkdownWebView: NSViewRepresentable {
    let markdown: String

    func makeNSView(context: Context) -> WKWebView {
        let webView = WKWebView(frame: .zero)
        webView.setValue(false, forKey: "drawsBackground")
        webView.navigationDelegate = context.coordinator
        load(into: webView)
        return webView
    }

    func updateNSView(_ webView: WKWebView, context: Context) {
        load(into: webView)
    }

    func makeCoordinator() -> Coordinator { Coordinator() }

    final class Coordinator: NSObject, WKNavigationDelegate {
        func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
            logger.log("didFinish navigation")
        }
        func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
            logger.error("didFail navigation: \(String(describing: error), privacy: .public)")
        }
        func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
            logger.error("didFailProvisionalNavigation: \(String(describing: error), privacy: .public)")
        }
    }

    private func load(into webView: WKWebView) {
        logger.log("markdown length: \(markdown.count, privacy: .public)")
        do {
            let html = try MarkdownHTMLBuilder.buildHTML(markdown: markdown, bundle: .main)
            logger.log("built html length: \(html.count, privacy: .public)")
            webView.loadHTMLString(html, baseURL: nil)
        } catch {
            logger.error("buildHTML failed: \(String(describing: error), privacy: .public)")
            webView.loadHTMLString("<p>Unable to render document.</p>", baseURL: nil)
        }
    }
}
