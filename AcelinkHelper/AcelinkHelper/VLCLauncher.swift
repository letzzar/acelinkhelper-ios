import UIKit

struct VLCLauncher {

    enum LaunchError: LocalizedError {
        case vlcNotInstalled
        case invalidStreamURL
        case failedToOpen

        var errorDescription: String? {
            switch self {
            case .vlcNotInstalled:
                return "VLC no está instalado. Descárgalo desde la App Store."
            case .invalidStreamURL:
                return "La URL del stream no es válida."
            case .failedToOpen:
                return "No se pudo abrir VLC."
            }
        }
    }

    @MainActor
    static func launch(streamURL: URL) async throws {
        let vlcURLString = "vlc://\(streamURL.absoluteString)"
        guard let vlcURL = URL(string: vlcURLString) else {
            throw LaunchError.invalidStreamURL
        }
        guard UIApplication.shared.canOpenURL(vlcURL) else {
            throw LaunchError.vlcNotInstalled
        }
        let opened = await UIApplication.shared.open(vlcURL)
        if !opened { throw LaunchError.failedToOpen }
    }
}
