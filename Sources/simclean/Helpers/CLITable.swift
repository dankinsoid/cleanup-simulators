struct CLITable {

    enum Alignment {
        case left, right
    }

    struct Column {
        let header: String
        let alignment: Alignment
        var minWidth: Int

        init(header: String, alignment: Alignment = .left, minWidth: Int? = nil) {
            self.header = header
            self.alignment = alignment
            self.minWidth = minWidth ?? header.count
        }
    }

    let columns: [Column]

    func render(rows: [[String]]) -> String {
        var widths = columns.map { max($0.minWidth, $0.header.count) }
        for row in rows {
            for (i, cell) in row.enumerated() where i < widths.count {
                widths[i] = max(widths[i], cell.count)
            }
        }

        var lines: [String] = []

        // Header
        let header = columns.enumerated().map { i, col in
            pad(col.header, width: widths[i], alignment: col.alignment)
        }.joined(separator: "  ")
        lines.append(header)

        // Separator
        lines.append(widths.map { String(repeating: "─", count: $0) }.joined(separator: "──"))

        // Rows
        for row in rows {
            let line = columns.enumerated().map { i, col in
                let cell = i < row.count ? row[i] : ""
                return pad(cell, width: widths[i], alignment: col.alignment)
            }.joined(separator: "  ")
            lines.append(line)
        }

        return lines.joined(separator: "\n")
    }

    private func pad(_ text: String, width: Int, alignment: Alignment) -> String {
        let padding = max(0, width - text.count)
        switch alignment {
        case .left:
            return text + String(repeating: " ", count: padding)
        case .right:
            return String(repeating: " ", count: padding) + text
        }
    }
}
