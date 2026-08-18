import SwiftUI

@main
struct LookMDApp: App {
    var body: some Scene {
        DocumentGroup(viewing: MarkdownDocument.self) { file in
            MarkdownWebView(markdown: file.document.text)
                .frame(minWidth: 480, minHeight: 360)
        }
    }
}
