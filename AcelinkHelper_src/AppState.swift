import Foundation
import Network

@MainActor
class AppState: ObservableObject {

    private static let appGroupID = "group.com.acelinkhelper.ios"
    private static var sharedDefaults: UserDefaults {
        UserDefaults(suiteName: appGroupID) ?? .standard
    }

    @Published var statusMessage: String = ""
    @Published var isError: Bool = false
    @Published var nasIP: String {
        didSet { AppState.sharedDefaults.set(nasIP, forKey: "nas_ip") }
    }

    private let server = StreamServer()

    init() {
        self.nasIP = AppState.sharedDefaults.string(forKey: "nas_ip") ?? ""
        server.onOpenURL = { [weak self] url in
            self?.handleIncomingURL(url)
        }
        server.start()
    }

    func handleIncomingURL(_ url: URL) {
        guard let streamURL = StreamHandler.buildStreamURL(from: url, nasIP: nasIP) else {
            statusMessage = nasIP.isEmpty ? "Configura la IP del NAS primero" : "URL no válida"
            isError = true
            return
        }

        Task {
            do {
                try await VLCLauncher.launch(streamURL: streamURL)
                statusMessage = "Abriendo en VLC…"
                isError = false
            } catch VLCLauncher.LaunchError.vlcNotInstalled {
                statusMessage = "VLC no está instalado en este dispositivo"
                isError = true
            } catch {
                statusMessage = error.localizedDescription
                isError = true
            }
        }
    }

    // Detecta la IP local del dispositivo (interfaz Wi-Fi en0)
    var deviceIP: String {
        var address = "No disponible"
        var ifaddr: UnsafeMutablePointer<ifaddrs>?
        guard getifaddrs(&ifaddr) == 0 else { return address }
        defer { freeifaddrs(ifaddr) }

        var ptr = ifaddr
        while let current = ptr {
            let interface = current.pointee
            if interface.ifa_addr.pointee.sa_family == UInt8(AF_INET),
               String(cString: interface.ifa_name) == "en0" {
                var hostname = [CChar](repeating: 0, count: Int(NI_MAXHOST))
                getnameinfo(interface.ifa_addr, socklen_t(interface.ifa_addr.pointee.sa_len),
                            &hostname, socklen_t(hostname.count), nil, 0, NI_NUMERICHOST)
                address = String(cString: hostname)
            }
            ptr = current.pointee.ifa_next
        }
        return address
    }
}
