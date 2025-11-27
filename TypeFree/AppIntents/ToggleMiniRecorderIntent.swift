import AppIntents
import AppKit
import Foundation

struct ToggleMiniRecorderIntent: AppIntent {
    static var title: LocalizedStringResource = "Toggle TypeFree Recorder"
    static var description = IntentDescription("Start or stop the TypeFree mini recorder for voice transcription.")

    static var openAppWhenRun: Bool = false

    @MainActor
    func perform() async throws -> some IntentResult & ProvidesDialog {
        NotificationCenter.default.post(name: .toggleMiniRecorder, object: nil)

        let dialog = IntentDialog(stringLiteral: "TypeFree recorder toggled")
        return .result(dialog: dialog)
    }
}

enum IntentError: Error, LocalizedError {
    case appNotAvailable
    case serviceNotAvailable

    var errorDescription: String? {
        switch self {
        case .appNotAvailable:
            "TypeFree app is not available"
        case .serviceNotAvailable:
            "TypeFree recording service is not available"
        }
    }
}
