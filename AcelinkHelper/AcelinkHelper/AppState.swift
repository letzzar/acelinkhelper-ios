import SwiftUI

@MainActor
class AppState: ObservableObject {

    private static let appGroupID = "group.com.acelinkhelper.ios"
    private static let nasIPKey = "nas_ip"

    @Published var nasIP: String
    @Published var statusMessage: String = ""
    @Published var isError: Bool = false
    @Published var pendingStreamURL: URL? = nil

    private let defaults: UserDefaults?
    private var server: StreamServer?

    init() {
        self.defaults = UserDefaults(suiteName: AppState.appGroupID)
        self.nasIP = defaults?.string(forKey: AppState.nasIPKey) ?? ""
    }

    func startServer() {
        guard server == nil else { return }
        server = StreamServer { [weak self] in
            self?.defaults?.string(forKey: AppState.nasIPKey) ?? ""
        }
        server?.start()
    }

    func stopServer() {
        server?.stop()
        server = nil
    }

    func saveNASIP() {
        let trimmed = nasIP.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else {
            showStatus("Introduce una IP válida", isError: true)
            return
        }
        nasIP = trimmed
        defaults?.set(trimmed, forKey: AppState.nasIPKey)
        showStatus("IP guardada: \(trimmed)", isError: false)
    }

    func handleIncomingURL(_ url: URL) {
        guard url.scheme == "acestream" else {
            showStatus("URL no reconocida", isError: true)
            return
        }

        let currentNASIP = defaults?.string(forKey: AppState.nasIPKey) ?? nasIP
        guard !currentNASIP.isEmpty else {
            showStatus("Configura la IP del NAS primero", isError: true)
            return
        }

        guard let streamURL = StreamHandler.buildStreamURL(from: url, nasIP: currentNASIP) else {
            showStatus("No se pudo extraer el ID de acestream", isError: true)
            return
        }

        pendingStreamURL = streamURL
        statusMessage = ""
        isError = false
    }

    func openInLocalVLC() {
        guard let url = pendingStreamURL else { return }
        showStatus("Abriendo en VLC…", isError: false)
        Task {
            do {
                try await VLCLauncher.launch(streamURL: url)
                showStatus("Stream enviado a VLC", isError: false)
            } catch {
                showStatus(error.localizedDescription, isError: true)
            }
        }
    }

    var m3uFileURL: URL? {
        guard let streamURL = pendingStreamURL else { return nil }
        let content = "#EXTM3U\n#EXTINF:-1,AcelinkHelper Stream\n\(streamURL.absoluteString)\n"
        let tmp = FileManager.default.temporaryDirectory.appendingPathComponent("stream.m3u")
        try? content.write(to: tmp, atomically: true, encoding: .utf8)
        return tmp
    }

    private func showStatus(_ message: String, isError: Bool) {
        self.statusMessage = message
        self.isError = isError
    }
}
