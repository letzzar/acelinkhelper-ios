import Foundation
import Network

class StreamServer {

    private var listener: NWListener?
    private let port: UInt16 = 8765
    private let nasIPProvider: () -> String

    init(nasIPProvider: @escaping () -> String) {
        self.nasIPProvider = nasIPProvider
    }

    func start() {
        do {
            let params = NWParameters.tcp
            listener = try NWListener(using: params, on: NWEndpoint.Port(rawValue: port)!)
        } catch {
            print("StreamServer: failed to create listener - \(error)")
            return
        }

        listener?.newConnectionHandler = { [weak self] connection in
            self?.handleConnection(connection)
        }

        listener?.stateUpdateHandler = { state in
            switch state {
            case .ready:
                print("StreamServer: listening on port \(self.port)")
            case .failed(let error):
                print("StreamServer: failed - \(error)")
            default:
                break
            }
        }

        listener?.start(queue: .global(qos: .userInitiated))
    }

    func stop() {
        listener?.cancel()
        listener = nil
    }

    private func handleConnection(_ connection: NWConnection) {
        connection.start(queue: .global(qos: .userInitiated))

        connection.receive(minimumIncompleteLength: 1, maximumLength: 65536) { [weak self] data, _, _, error in
            guard let self, let data, error == nil else {
                connection.cancel()
                return
            }

            let request = String(data: data, encoding: .utf8) ?? ""
            let response = self.processRequest(request)
            let responseData = Data(response.utf8)

            connection.send(content: responseData, completion: .contentProcessed { _ in
                connection.cancel()
            })
        }
    }

    private func processRequest(_ request: String) -> String {
        let lines = request.components(separatedBy: "\r\n")
        guard let requestLine = lines.first else {
            return httpResponse(status: "400 Bad Request", body: "Bad Request")
        }

        let parts = requestLine.split(separator: " ")
        guard parts.count >= 2 else {
            return httpResponse(status: "400 Bad Request", body: "Bad Request")
        }

        let method = String(parts[0])
        let path = String(parts[1])

        if method == "GET" && path == "/" {
            return httpResponse(status: "200 OK", body: htmlPage())
        }

        if method == "GET" && path.hasPrefix("/play?") {
            return handlePlay(path: path)
        }

        return httpResponse(status: "404 Not Found", body: "Not Found")
    }

    private func handlePlay(path: String) -> String {
        guard let urlComponents = URLComponents(string: "http://localhost\(path)"),
              let urlParam = urlComponents.queryItems?.first(where: { $0.name == "url" })?.value,
              let acestreamURL = URL(string: urlParam),
              acestreamURL.scheme == "acestream" else {
            return httpResponse(status: "400 Bad Request", body: "URL acestream inválida")
        }

        let nasIP = nasIPProvider()
        guard !nasIP.isEmpty else {
            return httpResponse(status: "400 Bad Request", body: "Configura la IP del NAS en la app primero")
        }

        guard let streamURL = StreamHandler.buildStreamURL(from: acestreamURL, nasIP: nasIP) else {
            return httpResponse(status: "400 Bad Request", body: "No se pudo procesar la URL")
        }

        let vlcURL = "vlc://\(streamURL.absoluteString)"
        let body = """
        <!DOCTYPE html>
        <html><head>
        <meta http-equiv="refresh" content="0;url=\(vlcURL)">
        </head><body>
        <p>Abriendo VLC…</p>
        <p><a href="\(vlcURL)">Pulsa aquí si no se abre automáticamente</a></p>
        </body></html>
        """

        return httpResponse(status: "200 OK", body: body)
    }

    private func htmlPage() -> String {
        """
        <!DOCTYPE html>
        <html lang="es">
        <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>AcelinkHelper</title>
        <style>
            * { margin: 0; padding: 0; box-sizing: border-box; }
            body {
                font-family: -apple-system, BlinkMacSystemFont, sans-serif;
                background: #0d0d1a;
                color: #fff;
                min-height: 100vh;
                display: flex;
                justify-content: center;
                align-items: center;
            }
            .container {
                width: 90%;
                max-width: 400px;
                padding: 32px;
                background: rgba(255,255,255,0.05);
                border-radius: 16px;
                text-align: center;
            }
            h1 { font-size: 24px; margin-bottom: 24px; color: #6b8cff; }
            input[type="text"] {
                width: 100%;
                padding: 12px 16px;
                border: 1px solid #333;
                border-radius: 10px;
                background: #1a1a2e;
                color: #fff;
                font-size: 16px;
                margin-bottom: 16px;
                outline: none;
            }
            input[type="text"]:focus { border-color: #6b8cff; }
            input[type="text"]::placeholder { color: #666; }
            button {
                width: 100%;
                padding: 12px;
                border: none;
                border-radius: 10px;
                background: #6b8cff;
                color: #fff;
                font-size: 16px;
                font-weight: 600;
                cursor: pointer;
            }
            button:active { opacity: 0.8; }
            .status { margin-top: 16px; font-size: 14px; color: #888; }
            .error { color: #ff6b6b; }
        </style>
        </head>
        <body>
        <div class="container">
            <h1>AcelinkHelper</h1>
            <form id="f">
                <input type="text" id="u" placeholder="acestream://..." autocomplete="off" autocapitalize="off">
                <button type="submit">Abrir en VLC</button>
            </form>
            <div class="status" id="s"></div>
        </div>
        <script>
        document.getElementById('f').addEventListener('submit', function(e) {
            e.preventDefault();
            var u = document.getElementById('u').value.trim();
            var s = document.getElementById('s');
            if (!u) { s.textContent = 'Introduce una URL'; s.className = 'status error'; return; }
            if (!u.startsWith('acestream://')) { s.textContent = 'La URL debe empezar con acestream://'; s.className = 'status error'; return; }
            s.textContent = 'Enviando…';
            s.className = 'status';
            window.location.href = '/play?url=' + encodeURIComponent(u);
        });
        </script>
        </body>
        </html>
        """
    }

    private func httpResponse(status: String, body: String) -> String {
        let contentType = body.contains("<html") ? "text/html; charset=utf-8" : "text/plain; charset=utf-8"
        return "HTTP/1.1 \(status)\r\nContent-Type: \(contentType)\r\nContent-Length: \(body.utf8.count)\r\nConnection: close\r\n\r\n\(body)"
    }
}
