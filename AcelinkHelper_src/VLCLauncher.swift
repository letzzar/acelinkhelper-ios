import UIKit

struct VLCLauncher {

    enum LaunchError: Error {
        case vlcNotInstalled
        case invalidURL
    }

    // VLC para iOS usa el esquema "vlc://" seguido de la URL del stream
    static func launch(streamURL: URL) async throws {
        guard let vlcURL = URL(string: "vlc://\(streamURL.absoluteString)") else {
            throw LaunchError.invalidURL
        }

        let canOpen = await UIApplication.shared.canOpenURL(vlcURL)
        guard canOpen else {
            throw LaunchError.vlcNotInstalled
        }

        await UIApplication.shared.open(vlcURL)
    }
}
