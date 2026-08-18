import Cocoa
import QuickLookUI
import WebKit
import os.log

private let logger = Logger(subsystem: "com.musikutiv.lookmd.QuickLookExtension", category: "preview")

final class PreviewViewController: NSViewController, QLPreviewingController {

    private let webView = WKWebView()

    override func loadView() {
        view = webView
    }

    func preparePreviewOfFile(at url: URL, completionHandler handler: @escaping (Error?) -> Void) {
        logger.log("preparePreviewOfFile called for \(url.path, privacy: .public)")
        do {
            let markdown = try String(contentsOf: url, encoding: .utf8)
            let bundle = Bundle(for: PreviewViewController.self)
            let html = try MarkdownHTMLBuilder.buildHTML(markdown: markdown, bundle: bundle)
            webView.loadHTMLString(html, baseURL: nil)
            handler(nil)
        } catch {
            logger.error("preparePreviewOfFile failed: \(String(describing: error), privacy: .public)")
            handler(error)
        }
    }
}
