import Foundation

extension WhisperState {
    var usableModels: [any TranscriptionModel] {
        allAvailableModels.filter { model in
            switch model.provider {
            case .local:
                availableModels.contains { $0.name == model.name }
            case .parakeet:
                isParakeetModelDownloaded(named: model.name)
            case .nativeApple:
                if #available(macOS 26, *) {
                    true
                } else {
                    false
                }
            case .custom:
                // Custom models are always usable since they contain their own API keys
                true
            }
        }
    }
}
