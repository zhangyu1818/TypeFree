import Foundation
import os

enum CloudTranscriptionError: Error, LocalizedError {
    case unsupportedProvider
    case missingAPIKey
    case invalidAPIKey
    case audioFileNotFound
    case apiRequestFailed(statusCode: Int, message: String)
    case networkError(Error)
    case noTranscriptionReturned
    case dataEncodingError

    var errorDescription: String? {
        switch self {
        case .unsupportedProvider:
            "The model provider is not supported by this service."
        case .missingAPIKey:
            "API key for this service is missing. Please configure it in the settings."
        case .invalidAPIKey:
            "The provided API key is invalid."
        case .audioFileNotFound:
            "The audio file to transcribe could not be found."
        case let .apiRequestFailed(statusCode, message):
            "The API request failed with status code \(statusCode): \(message)"
        case let .networkError(error):
            "A network error occurred: \(error.localizedDescription)"
        case .noTranscriptionReturned:
            "The API returned an empty or invalid response."
        case .dataEncodingError:
            "Failed to encode the request body."
        }
    }
}

class CloudTranscriptionService: TranscriptionService {
    private lazy var openAICompatibleService = OpenAICompatibleTranscriptionService()

    func transcribe(audioURL: URL, model: any TranscriptionModel) async throws -> String {
        var text: String

        switch model.provider {
        case .custom:
            guard let customModel = model as? CustomCloudModel else {
                throw CloudTranscriptionError.unsupportedProvider
            }
            text = try await openAICompatibleService.transcribe(audioURL: audioURL, model: customModel)
        default:
            throw CloudTranscriptionError.unsupportedProvider
        }

        return text
    }
}
