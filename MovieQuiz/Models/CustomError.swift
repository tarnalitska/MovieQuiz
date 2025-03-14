import Foundation

enum CustomError: Error, LocalizedError {
    case apiError(message: String)
    case emptyMovies
    case imageLoadingFail
    
    var errorDescription: String? {
        switch self {
        case .apiError(let message):
            return message
        case .emptyMovies:
            return "No movies found"
        case .imageLoadingFail:
            return "Failed to load image"
        }
    }
}
