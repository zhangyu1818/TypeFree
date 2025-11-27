import AppIntents
import AppKit
import Foundation

struct DismissMiniRecorderIntent: AppIntent {
    static var title: LocalizedStringResource = "Dismiss TypeFree Recorder"
    static var description = IntentDescription("Dismiss the TypeFree mini recorder and cancel any active recording.")

    static var openAppWhenRun: Bool = false

    @MainActor
    func perform() async throws -> some IntentResult & ProvidesDialog {
        NotificationCenter.default.post(name: .dismissMiniRecorder, object: nil)

        let dialog = IntentDialog(stringLiteral: "TypeFree recorder dismissed")
        return .result(dialog: dialog)
    }
}
