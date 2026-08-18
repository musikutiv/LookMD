import Foundation
import QuickLookUI
import UniformTypeIdentifiers

final class PreviewProvider: QLPreviewProvider, QLPreviewingController {

    func providePreview(for request: QLFilePreviewRequest, completionHandler handler: @escaping (QLPreviewReply?, Error?) -> Void) {
        do {
            let markdown = try String(contentsOf: request.fileURL, encoding: .utf8)
            let bundle = Bundle(for: PreviewProvider.self)
            let html = try MarkdownHTMLBuilder.buildHTML(markdown: markdown, bundle: bundle)
            let reply = QLPreviewReply(dataOfContentType: .html, contentSize: CGSize(width: 900, height: 700)) { _ in
                Data(html.utf8)
            }
            reply.stringEncoding = .utf8
            handler(reply, nil)
        } catch {
            handler(nil, error)
        }
    }
}
