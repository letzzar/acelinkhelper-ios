import Foundation
import Network

class TVStreamServer {

    private static let port: UInt16 = 8765
    private static let nasIPKey = "nas_ip"

    private var listener: NWListener?
    private let vlcLauncher: (URL) async -> Bool

    init(vlcLauncher: @escaping (URL) async -> Bool) {
        self.vlcLauncher = vlcLauncher
    }

    func start() {
        do {
            listener = try NWListener(using: .tcp, on: NWEndpoint.Port(rawValue: TVStreamServer.port)!)
        } catch {
            print("TVStreamServer: \(error)")
            return
        }
        listener?.newConnectionHandler = { [weak self] conn in self?.handle(conn) }
        listener?.start(queue: .global(qos: .userInitiated))
    }

    func stop() {
        listener?.cancel()
        listener = nil
    }

    // MARK: - Connection

    private func handle(_ connection: NWConnection) {
        connection.start(queue: .global(qos: .userInitiated))
        connection.receive(minimumIncompleteLength: 1, maximumLength: 65536) { [weak self] data, _, _, error in
            guard let self, let data, error == nil else { connection.cancel(); return }
            let raw = String(data: data, encoding: .utf8) ?? ""
            self.respond(to: raw, on: connection)
        }
    }

    private func respond(to raw: String, on connection: NWConnection) {
        let parts = raw.components(separatedBy: "\r\n\r\n")
        let headers = parts.first ?? ""
        let body = parts.count > 1 ? parts[1] : ""

        let requestLine = headers.components(separatedBy: "\r\n").first ?? ""
        let tokens = requestLine.split(separator: " ")
        guard tokens.count >= 2 else { send(badRequest(), on: connection); return }

        let method = String(tokens[0])
        let path   = String(tokens[1])

        switch (method, path) {
        case ("GET",  "/"):         send(html(htmlPage()), on: connection)
        case ("GET",  "/config"):   send(json(configJSON()), on: connection)
        case ("POST", "/play"):     handlePlay(body: body, on: connection)
        case ("POST", "/save-ip"):  send(json(handleSaveIP(body: body)), on: connection)
        default:                    send(notFound(), on: connection)
        }
    }

    // MARK: - Handlers

    private func handlePlay(body: String, on connection: NWConnection) {
        let params = parseForm(body)
        guard let urlStr = params["url"], !urlStr.isEmpty else {
            send(json(err("Falta el parámetro url")), on: connection); return
        }
        guard let acestreamURL = URL(string: urlStr), acestreamURL.scheme == "acestream" else {
            send(json(err("URL acestream inválida")), on: connection); return
        }
        let ip = nasIP
        guard !ip.isEmpty else {
            send(json(err("Configura la IP del NAS primero")), on: connection); return
        }
        let id: String
        if let host = acestreamURL.host, !host.isEmpty {
            id = host
        } else {
            let p = acestreamURL.path
            id = p.hasPrefix("/") ? String(p.dropFirst()) : p
        }
        guard !id.isEmpty, let streamURL = URL(string: "http://\(ip):6878/ace/getstream?id=\(id)") else {
            send(json(err("ID de acestream inválido")), on: connection); return
        }

        // Return success immediately — VLC opens async on main thread
        send(json(#"{"ok":true,"msg":"Abriendo VLC en Apple TV…"}"#), on: connection)

        Task { @MainActor [weak self] in
            _ = await self?.vlcLauncher(streamURL)
        }
    }

    private func handleSaveIP(body: String) -> String {
        let params = parseForm(body)
        guard let ip = params["nas_ip"]?.trimmingCharacters(in: .whitespaces), !ip.isEmpty else {
            return err("IP inválida")
        }
        nasIP = ip
        return #"{"ok":true}"#
    }

    private func configJSON() -> String {
        let ip = nasIP
        return "{\"nas_ip\":\"\(escapeJSON(ip))\"}"
    }

    // MARK: - NAS IP storage

    private var nasIP: String {
        get { UserDefaults.standard.string(forKey: TVStreamServer.nasIPKey) ?? "" }
        set { UserDefaults.standard.set(newValue, forKey: TVStreamServer.nasIPKey) }
    }

    // MARK: - Helpers

    private func parseForm(_ body: String) -> [String: String] {
        var result = [String: String]()
        for pair in body.components(separatedBy: "&") {
            let kv = pair.components(separatedBy: "=")
            guard kv.count >= 2 else { continue }
            let key = kv[0].removingPercentEncoding ?? kv[0]
            let val = kv[1...].joined(separator: "=")
                .replacingOccurrences(of: "+", with: " ")
                .removingPercentEncoding ?? kv[1]
            result[key] = val
        }
        return result
    }

    private func escapeJSON(_ s: String) -> String {
        s.replacingOccurrences(of: "\\", with: "\\\\").replacingOccurrences(of: "\"", with: "\\\"")
    }

    private func err(_ msg: String) -> String {
        "{\"ok\":false,\"error\":\"\(escapeJSON(msg))\"}"
    }

    // MARK: - HTTP responses

    private func send(_ response: String, on connection: NWConnection) {
        connection.send(content: Data(response.utf8), completion: .contentProcessed { _ in connection.cancel() })
    }

    private func html(_ body: String) -> String {
        "HTTP/1.1 200 OK\r\nContent-Type: text/html; charset=utf-8\r\nContent-Length: \(body.utf8.count)\r\nConnection: close\r\n\r\n\(body)"
    }

    private func json(_ body: String) -> String {
        "HTTP/1.1 200 OK\r\nContent-Type: application/json\r\nContent-Length: \(body.utf8.count)\r\nConnection: close\r\n\r\n\(body)"
    }

    private func badRequest() -> String {
        "HTTP/1.1 400 Bad Request\r\nContent-Length: 0\r\nConnection: close\r\n\r\n"
    }

    private func notFound() -> String {
        "HTTP/1.1 404 Not Found\r\nContent-Length: 0\r\nConnection: close\r\n\r\n"
    }

    // MARK: - Web page

    private func htmlPage() -> String {
        """
        <!DOCTYPE html>
        <html lang="es">
        <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>AcelinkHelper TV</title>
        <style>
          * { box-sizing: border-box; margin: 0; padding: 0; }
          body {
            background: #0d0d1a; color: #e0e0f0;
            font-family: -apple-system, system-ui, sans-serif;
            min-height: 100vh; display: flex; flex-direction: column;
            align-items: center; padding: 2rem 1rem;
          }
          h1 { font-size: 2rem; color: #6b8cff; margin-bottom: 2rem; }
          h1 span { color: #a0b8ff; font-weight: 300; }
          .card {
            background: #16162a; border: 1px solid #2a2a50;
            border-radius: 14px; padding: 1.5rem;
            width: 100%; max-width: 560px; margin-bottom: 1.25rem;
          }
          h2 {
            font-size: 0.85rem; font-weight: 600; color: #8098ff;
            text-transform: uppercase; letter-spacing: 0.08em; margin-bottom: 1rem;
          }
          .row { display: flex; gap: 0.6rem; }
          input {
            flex: 1; background: #0d0d1a; border: 1px solid #2e2e5a;
            border-radius: 8px; color: #e0e0f0; font-size: 1rem;
            padding: 0.7rem 1rem;
          }
          input:focus { outline: none; border-color: #6b8cff; }
          input::placeholder { color: #555; }
          button {
            background: #4a6cf7; border: none; border-radius: 8px;
            color: #fff; cursor: pointer; font-size: 0.95rem;
            font-weight: 600; padding: 0.7rem 1.2rem; white-space: nowrap;
          }
          button:hover { background: #6080ff; }
          .msg { margin-top: 0.75rem; font-size: 0.9rem; min-height: 1.3rem; }
          .ok  { color: #5fdd7c; }
          .err { color: #ff6060; }
          #qr-img { display: block; margin: 0 auto 0.75rem;
                    border-radius: 10px; background: #fff; padding: 6px; }
          #qr-url { text-align: center; font-size: 0.85rem; color: #6b8cff;
                    font-family: monospace; word-break: break-all; }
        </style>
        </head>
        <body>
        <h1>Acelink<span>Helper</span> TV</h1>

        <div class="card" style="text-align:center;">
          <h2>Abrir esta página desde el móvil</h2>
          <img id="qr-img" width="180" height="180" src="" alt="" />
          <p id="qr-url"></p>
        </div>

        <div class="card">
          <h2>Servidor AceStream (NAS)</h2>
          <div class="row">
            <input id="nas-ip" type="text" placeholder="192.168.1.100" autocomplete="off" />
            <button onclick="saveIp()">Guardar</button>
          </div>
          <div id="ip-msg" class="msg"></div>
        </div>

        <div class="card">
          <h2>Reproducir en Apple TV</h2>
          <div class="row">
            <input id="stream-url" type="text" placeholder="acestream://abc123..." autocomplete="off" />
            <button onclick="play()">&#9654; VLC</button>
          </div>
          <div id="play-msg" class="msg"></div>
        </div>

        <script>
        (function() {
          const base = window.location.origin;
          document.getElementById('qr-url').textContent = base;
          const img = document.getElementById('qr-img');
          img.src = 'https://api.qrserver.com/v1/create-qr-code/?size=200x200&data=' + encodeURIComponent(base);
          img.onerror = function() { this.style.display = 'none'; };
        })();

        fetch('/config').then(r => r.json())
          .then(d => { if (d.nas_ip) document.getElementById('nas-ip').value = d.nas_ip; })
          .catch(() => {});

        function saveIp() {
          const ip = document.getElementById('nas-ip').value.trim();
          const msg = document.getElementById('ip-msg');
          if (!ip) { show(msg, 'Introduce la IP', false); return; }
          post('/save-ip', { nas_ip: ip })
            .then(d => show(msg, d.ok ? 'IP guardada' : d.error, d.ok));
        }

        function play() {
          const url = document.getElementById('stream-url').value.trim();
          const msg = document.getElementById('play-msg');
          if (!url) { show(msg, 'Introduce un enlace acestream://', false); return; }
          show(msg, 'Enviando…', true);
          post('/play', { url })
            .then(d => show(msg, d.ok ? d.msg || '¡Abriendo VLC!' : d.error, d.ok));
        }

        function post(path, data) {
          const body = Object.entries(data)
            .map(([k, v]) => encodeURIComponent(k) + '=' + encodeURIComponent(v))
            .join('&');
          return fetch(path, {
            method: 'POST',
            headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
            body
          }).then(r => r.json()).catch(() => ({ ok: false, error: 'Error de conexión' }));
        }

        function show(el, text, ok) {
          el.textContent = text;
          el.className = 'msg ' + (ok ? 'ok' : 'err');
        }

        ['stream-url', 'nas-ip'].forEach(id => {
          document.getElementById(id).addEventListener('keydown', e => {
            if (e.key === 'Enter') id === 'stream-url' ? play() : saveIp();
          });
        });
        </script>
        </body>
        </html>
        """
    }
}
