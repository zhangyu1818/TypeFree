import Foundation

enum WhisperStateError: Error, Identifiable {
    case modelLoadFailed
    case transcriptionFailed
    case whisperCoreFailed
    case unzipFailed
    case unknownError

    var id: String { UUID().uuidString }
}

extension WhisperStateError: LocalizedError {
    var errorDescription: String? {
        switch self {
        case .modelLoadFailed:
            "Failed to load the transcription model."
        case .transcriptionFailed:
            "Failed to transcribe the audio."
        case .whisperCoreFailed:
            "The core transcription engine failed."
        case .unzipFailed:
            "Failed to unzip the downloaded Core ML model."
        case .unknownError:
            "An unknown error occurred."
        }
    }

    var recoverySuggestion: String? {
        switch self {
        case .modelLoadFailed:
            "Try selecting a different model or redownloading the current model."
        case .transcriptionFailed:
            "Check the default model try again. If the problem persists, try a different model."
        case .whisperCoreFailed:
            "This can happen due to an issue with the audio recording or insufficient system resources. Please try again, or restart the app."
        case .unzipFailed:
            "The downloaded Core ML model archive might be corrupted. Try deleting the model and downloading it again. Check available disk space."
        case .unknownError:
            "Please restart the application. If the problem persists, contact support."
        }
    }
}
