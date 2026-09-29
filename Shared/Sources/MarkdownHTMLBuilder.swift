import Foundation

enum MarkdownHTMLBuilder {

    enum BuilderError: Error {
        case templateNotFound
        case markedJSNotFound
        case templateUnreadable
    }

    static func buildHTML(markdown: String, bundle: Bundle, baseURL: URL? = nil) throws -> String {
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

        let (frontmatter, body) = extractFrontmatter(from: markdown)

        let jsonData = try JSONEncoder().encode(body)
        let jsonString = String(data: jsonData, encoding: .utf8) ?? "\"\""
        // Guard against premature </script> termination inside the payload.
        let safeJSON = jsonString.replacingOccurrences(of: "</script>", with: "<\\/script>")
        let safeMarkedJS = markedJS.replacingOccurrences(of: "</script>", with: "<\\/script>")
        let baseTag = baseURL.map { "<base href=\"\(escapeHTML($0.absoluteString))\">" } ?? ""

        return template
            .replacingOccurrences(of: "%%MARKED_JS%%", with: safeMarkedJS)
            .replacingOccurrences(of: "%%MARKDOWN_JSON%%", with: safeJSON)
            .replacingOccurrences(of: "%%FRONTMATTER_HTML%%", with: frontmatterHTML(frontmatter))
            .replacingOccurrences(of: "%%BASE_TAG%%", with: baseTag)
    }

    // MARK: - YAML frontmatter (R Markdown / Quarto)

    /// Splits a leading `---`-delimited YAML block off the front of the document.
    /// Only used to surface title/author/date as a header; not a general YAML parser.
    private static func extractFrontmatter(from markdown: String) -> (fields: [(key: String, value: String)], body: String) {
        let lines = markdown.components(separatedBy: "\n")
        guard lines.first?.trimmingCharacters(in: .whitespaces) == "---" else {
            return ([], markdown)
        }
        guard let endIndex = lines.dropFirst().firstIndex(where: { $0.trimmingCharacters(in: .whitespaces) == "---" }) else {
            return ([], markdown)
        }

        var fields: [(key: String, value: String)] = []
        for line in lines[1..<endIndex] {
            guard !line.hasPrefix(" ") && !line.hasPrefix("\t"), let colon = line.firstIndex(of: ":") else { continue }
            let key = line[line.startIndex..<colon].trimmingCharacters(in: .whitespaces)
            var value = line[line.index(after: colon)...].trimmingCharacters(in: .whitespaces)
            if value.hasPrefix("\""), value.hasSuffix("\""), value.count >= 2 {
                value = String(value.dropFirst().dropLast())
            } else if value.hasPrefix("'"), value.hasSuffix("'"), value.count >= 2 {
                value = String(value.dropFirst().dropLast())
            }
            if !key.isEmpty, !value.isEmpty {
                fields.append((key, value))
            }
        }

        let body = lines[(endIndex + 1)...].joined(separator: "\n")
        return (fields, body)
    }

    private static func frontmatterHTML(_ fields: [(key: String, value: String)]) -> String {
        let lookup = Dictionary(fields.map { ($0.key.lowercased(), $0.value) }, uniquingKeysWith: { first, _ in first })
        guard let title = lookup["title"] else { return "" }

        var meta: [String] = []
        if let author = lookup["author"] { meta.append(escapeHTML(author)) }
        if let date = lookup["date"] { meta.append(escapeHTML(date)) }

        var html = "<h1 class=\"fm-title\">\(escapeHTML(title))</h1>"
        if !meta.isEmpty {
            html += "<div class=\"fm-meta\">\(meta.joined(separator: " · "))</div>"
        }
        return html
    }

    private static func escapeHTML(_ string: String) -> String {
        string
            .replacingOccurrences(of: "&", with: "&amp;")
            .replacingOccurrences(of: "<", with: "&lt;")
            .replacingOccurrences(of: ">", with: "&gt;")
            .replacingOccurrences(of: "\"", with: "&quot;")
    }
}
