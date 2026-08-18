import Foundation

enum MarkdownHTMLBuilder {

    enum BuilderError: Error {
        case templateNotFound
        case markedJSNotFound
        case templateUnreadable
    }

    static func buildHTML(markdown: String, bundle: Bundle) throws -> String {
        guard let templateURL = bundle.url(forResource: "render", withExtension: "html") else {
            throw BuilderError.templateNotFound
        }
        guard let markedURL = bundle.url(forResource: "marked.min", withExtension: "js") else {
            throw BuilderError.markedJSNotFound
        }
        guard let template = try? String(contentsOf: templateURL, encoding: .utf8),
              let markedJS = try? String(contentsOf: markedURL, encoding: .utf8) else {
            throw BuilderError.templateUnreadable
        }

        let jsonData = try JSONEncoder().encode(markdown)
        let jsonString = String(data: jsonData, encoding: .utf8) ?? "\"\""
        // Guard against premature </script> termination inside the payload.
        let safeJSON = jsonString.replacingOccurrences(of: "</script>", with: "<\\/script>")
        let safeMarkedJS = markedJS.replacingOccurrences(of: "</script>", with: "<\\/script>")

        return template
            .replacingOccurrences(of: "%%MARKED_JS%%", with: safeMarkedJS)
            .replacingOccurrences(of: "%%MARKDOWN_JSON%%", with: safeJSON)
    }
}
