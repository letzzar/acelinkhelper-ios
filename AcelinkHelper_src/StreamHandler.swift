import Foundation

struct StreamHandler {

    static func buildStreamURL(from url: URL, nasIP: String) -> URL? {
        guard url.scheme == "acestream",
              !nasIP.trimmingCharacters(in: .whitespaces).isEmpty else {
            return nil
        }
        let contentID = url.host ?? url.path.trimmingCharacters(in: CharacterSet(charactersIn: "/"))
        guard !contentID.isEmpty else { return nil }
        return URL(string: "http://\(nasIP):6878/ace/getstream?id=\(contentID)")
    }
}
