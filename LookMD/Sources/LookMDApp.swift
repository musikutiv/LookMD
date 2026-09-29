import SwiftUI

@main
struct LookMDApp: App {
    var body: some Scene {
        DocumentGroup(viewing: MarkdownDocument.self) { file in
            MarkdownDocumentView(markdown: file.document.text, fileURL: file.fileURL)
        }
        .commands {
            CommandGroup(after: .saveItem) {
                ExportCommands()
            }
        }
    }
}

private struct ExportCommands: View {
    @FocusedValue(\.exportActions) private var exportActions

    var body: some View {
        Button("Export as HTML…") {
            exportActions?.exportHTML()
        }
        .keyboardShortcut("e", modifiers: [.command, .shift])
        .disabled(exportActions == nil)

        Button("Export as PDF…") {
            exportActions?.exportPDF()
        }
        .keyboardShortcut("e", modifiers: [.command, .shift, .option])
        .disabled(exportActions == nil)
    }
}
