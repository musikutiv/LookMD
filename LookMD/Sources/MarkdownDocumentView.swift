import SwiftUI
import WebKit
import UniformTypeIdentifiers

/// Holds the WKWebView outside of SwiftUI's state system: setting it happens inside
/// NSViewRepresentable.makeNSView, and mutating @State there races the current render
/// pass (the assignment can be dropped, leaving PDF export reading a stale nil).
private final class WebViewHolder {
    var webView: WKWebView?
}

struct MarkdownDocumentView: View {
    let markdown: String
    let fileURL: URL?

    @State private var webViewHolder = WebViewHolder()

    private var baseURL: URL? {
        fileURL?.deletingLastPathComponent()
    }

    private var suggestedFileName: String {
        fileURL?.deletingPathExtension().lastPathComponent ?? "Untitled"
    }

    var body: some View {
        MarkdownWebView(markdown: markdown, baseURL: baseURL) { webViewHolder.webView = $0 }
            .frame(minWidth: 480, minHeight: 360)
            .focusedSceneValue(\.exportActions, ExportActions(
                exportHTML: exportHTML,
                exportPDF: exportPDF
            ))
    }

    private func exportHTML() {
        guard let html = try? MarkdownHTMLBuilder.buildHTML(markdown: markdown, bundle: .main, baseURL: baseURL) else {
            return
        }

        let panel = NSSavePanel()
        panel.allowedContentTypes = [.html]
        panel.nameFieldStringValue = "\(suggestedFileName).html"
        panel.begin { response in
            guard response == .OK, let url = panel.url else { return }
            try? html.write(to: url, atomically: true, encoding: .utf8)
        }
    }

    private func exportPDF() {
        guard let webView = webViewHolder.webView else { return }

        let panel = NSSavePanel()
        panel.allowedContentTypes = [.pdf]
        panel.nameFieldStringValue = "\(suggestedFileName).pdf"
        panel.begin { response in
            guard response == .OK, let url = panel.url else { return }
            webView.createPDF(configuration: WKPDFConfiguration()) { result in
                guard let data = try? result.get() else { return }
                try? data.write(to: url)
            }
        }
    }
}
