import SwiftUI
import UniformTypeIdentifiers

struct MarkdownDocument: FileDocument {
    static var readableContentTypes: [UTType] = [.markdownText, .rMarkdownText, .quartoText]

    var text: String

    init(text: String = "") {
        self.text = text
    }

    init(configuration: ReadConfiguration) throws {
        guard let data = configuration.file.regularFileContents,
              let string = String(data: data, encoding: .utf8) else {
            throw CocoaError(.fileReadCorruptFile)
        }
        text = string
    }

    func fileWrapper(configuration: WriteConfiguration) throws -> FileWrapper {
        FileWrapper(regularFileWithContents: Data(text.utf8))
    }
}

extension UTType {
    static var markdownText: UTType {
        UTType(importedAs: "net.daringfireball.markdown")
    }
    static var rMarkdownText: UTType {
        UTType(importedAs: "com.musikutiv.lookmd.rmarkdown")
    }
    static var quartoText: UTType {
        UTType(importedAs: "com.musikutiv.lookmd.qmd")
    }
}
