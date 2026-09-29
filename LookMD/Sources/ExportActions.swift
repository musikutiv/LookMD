import SwiftUI

struct ExportActions {
    let exportHTML: () -> Void
    let exportPDF: () -> Void
}

private struct ExportActionsKey: FocusedValueKey {
    typealias Value = ExportActions
}

extension FocusedValues {
    var exportActions: ExportActions? {
        get { self[ExportActionsKey.self] }
        set { self[ExportActionsKey.self] = newValue }
    }
}
