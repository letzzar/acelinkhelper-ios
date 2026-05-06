import Foundation
import Network

final class StreamServer {

    static let port: UInt16 = 8765

    // Called on the main thread when a URL open is requested from the web UI
    var onOpenURL: ((URL) -> Void)?

    private var listener: NWListener?
    private let queue = DispatchQueue(label: "com.acelinkhelper.server", qos: .utility)

    func start() {
        guard listener == nil else { return }
        do {
            let params = NWParameters.tcp
            params.allowLocalEndpointReuse = true
            let l = try NWListener(using: params, on: NWEndpoint.Port(rawValue: Self.port)!)
            listener = l
            l.stateUpdateHandler = { _ in }
            l.newConnectionHandler = { [weak self] in self?.handle($0) }
            l.start(queue: queue)
        } catch { }
    }

    func stop() {
        listener?.cancel()
        listener = nil
    }

    // MARK: - Connection handling

    private func handle(_ connection: NWConnection) {
        connection.start(queue: queue)
        connection.receive(minimumIncompleteLength: 1, maximumLength: 8192) { [weak self] data, _, _, _ in
            guard let self, let data, let text = String(data: data, encoding: .utf8) else {
                connection.cancel()
                return
            }
            self.respond(to: text, on: connection)
        }
    }

    private func respond(to request: String, on connection: NWConnection) {
        let path = requestPath(from: request)

        if path.hasPrefix("/open"),
           let rawURL = queryValue("url", in: path),
           let decoded = rawURL.removingPercentEncoding,
           let url = URL(string: decoded) {
            let callback = onOpenURL
            DispatchQueue.main.async { callback?(url) }
            reply(html: Self.confirmHTML, status: "200 OK", on: connection)
        } else {
            reply(html: Self.indexHTML, status: "200 OK", on: connection)
        }
    }

    // MARK: - HTTP helpers

    private func requestPath(from raw: String) -> String {
        raw.components(separatedBy: "\r\n").first?
            .components(separatedBy: " ")
            .dropFirst().first
            .map(String.init) ?? "/"
    }

    private func queryValue(_ key: String, in path: String) -> String? {
        URLComponents(string: "http://x\(path)")?.queryItems?.first { $0.name == key }?.value
    }

    private func reply(html body: String, status: String, on connection: NWConnection) {
        let bodyData = Data(body.utf8)
        let header = "HTTP/1.1 \(status)\r\n"
                   + "Content-Type: text/html; charset=utf-8\r\n"
                   + "Content-Length: \(bodyData.count)\r\n"
                   + "Connection: close\r\n\r\n"
        let response = Data(header.utf8) + bodyData
        connection.send(content: response, completion: .contentProcessed { _ in connection.cancel() })
    }
}

// MARK: - HTML pages

private extension StreamServer {

    static let indexHTML = """
    <!DOCTYPE html>
    <html lang="es">
    <head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width,initial-scale=1">
    <title>AcelinkHelper</title>
    <style>
      *{box-sizing:border-box;margin:0;padding:0}
      body{background:#0d0d1a;color:#fff;font-family:-apple-system,sans-serif;
           min-height:100vh;display:flex;align-items:center;justify-content:center;padding:24px}
      .card{background:rgba(255,255,255,.05);border-radius:16px;padding:32px;
            width:100%;max-width:480px}
      h1{font-size:1.8rem;margin-bottom:4px}
      .sub{color:#6b8cff;font-size:.9rem;margin-bottom:28px}
      label{font-size:.8rem;color:#aaa;display:block;margin-bottom:6px}
      input{width:100%;background:rgba(255,255,255,.08);border:none;border-radius:10px;
            padding:12px;color:#fff;font-size:1rem;font-family:monospace;outline:none}
      input:focus{box-shadow:0 0 0 2px #6b8cff}
      button{margin-top:12px;width:100%;background:#6b8cff;border:none;
             border-radius:10px;padding:14px;color:#fff;font-size:1rem;
             font-weight:600;cursor:pointer}
      button:active{opacity:.8}
      .hint{margin-top:16px;font-size:.75rem;color:#555;text-align:center}
    </style>
    </head>
    <body>
    <div class="card">
      <h1>AcelinkHelper</h1>
      <p class="sub">Interfaz web — enviar stream al iPhone</p>
      <form action="/open" method="get">
        <label for="u">Enlace acestream://</label>
        <input id="u" name="url" type="text"
               placeholder="acestream://..."
               autocorrect="off" autocapitalize="off"
               spellcheck="false" required>
        <button type="submit">Abrir en VLC &rarr;</button>
      </form>
      <p class="hint">El stream se abrirá en VLC en tu iPhone</p>
    </div>
    </body>
    </html>
    """

    static let confirmHTML = """
    <!DOCTYPE html>
    <html lang="es">
    <head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width,initial-scale=1">
    <meta http-equiv="refresh" content="3;url=/">
    <title>AcelinkHelper</title>
    <style>
      *{box-sizing:border-box;margin:0;padding:0}
      body{background:#0d0d1a;color:#fff;font-family:-apple-system,sans-serif;
           min-height:100vh;display:flex;align-items:center;justify-content:center}
      .msg{text-align:center;padding:24px}
      h2{color:#4ade80;font-size:1.5rem;margin-bottom:8px}
      p{color:#aaa;font-size:.9rem}
    </style>
    </head>
    <body>
    <div class="msg">
      <h2>&#10003; Abriendo en VLC&hellip;</h2>
      <p>Volviendo al formulario en 3 segundos</p>
    </div>
    </body>
    </html>
    """
}
