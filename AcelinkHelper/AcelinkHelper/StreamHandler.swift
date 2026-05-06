import Foundation

struct StreamHandler {

    static func extractAcestreamID(from url: URL) -> String? {
        guard url.scheme == "acestream" else { return nil }

        if let host = url.host, !host.isEmpty {
            return host
        }

        let path = url.path
        if !path.isEmpty {
            let id = path.hasPrefix("/") ? String(path.dropFirst()) : path
            if !id.isEmpty {
                return id
            }
        }

        return nil
    }

    static func buildStreamURL(from acestreamURL: URL, nasIP: String) -> URL? {
        guard let id = extractAcestreamID(from: acestreamURL) else { return nil }
        return URL(string: "http://\(nasIP):6878/ace/getstream?id=\(id)")
    }
}
