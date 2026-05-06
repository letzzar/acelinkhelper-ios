import SwiftUI
import UIKit

@MainActor
class TVAppState: ObservableObject {

    private static let nasIPKey = "nas_ip"

    @Published var nasIP: String
    @Published var statusMessage: String = ""
    @Published var isError: Bool = false
    @Published var deviceIP: String = "Buscando IP…"

    private var server: TVStreamServer?

    init() {
        self.nasIP = UserDefaults.standard.string(forKey: TVAppState.nasIPKey) ?? ""
        self.deviceIP = TVAppState.getDeviceIP() ?? "Sin red"
    }

    func startServer() {
        guard server == nil else { return }
        server = TVStreamServer { [weak self] streamURL in
            await self?.launchVLC(streamURL: streamURL) ?? false
        }
        server?.start()
    }

    private func launchVLC(streamURL: URL) async -> Bool {
        let vlcURLString = "vlc://\(streamURL.absoluteString)"
        guard let vlcURL = URL(string: vlcURLString),
              UIApplication.shared.canOpenURL(vlcURL) else {
            showStatus("VLC no está instalado", isError: true)
            return false
        }
        let opened = await UIApplication.shared.open(vlcURL)
        if opened {
            showStatus("Stream enviado a VLC", isError: false)
        } else {
            showStatus("No se pudo abrir VLC", isError: true)
        }
        return opened
    }

    private func showStatus(_ message: String, isError: Bool) {
        self.statusMessage = message
        self.isError = isError
    }

    static func getDeviceIP() -> String? {
        var ifaddr: UnsafeMutablePointer<ifaddrs>?
        guard getifaddrs(&ifaddr) == 0, let first = ifaddr else { return nil }
        defer { freeifaddrs(ifaddr) }
        for ptr in sequence(first: first, next: { $0.pointee.ifa_next }) {
            let iface = ptr.pointee
            guard iface.ifa_addr.pointee.sa_family == UInt8(AF_INET) else { continue }
            let name = String(cString: iface.ifa_name)
            guard name == "en0" || name == "en1" else { continue }
            var host = [CChar](repeating: 0, count: Int(NI_MAXHOST))
            getnameinfo(iface.ifa_addr, socklen_t(iface.ifa_addr.pointee.sa_len),
                        &host, socklen_t(host.count), nil, 0, NI_NUMERICHOST)
            let ip = String(cString: host)
            if !ip.isEmpty { return ip }
        }
        return nil
    }
}
