import UIKit
import UniformTypeIdentifiers

// NOTA Xcode: añade StreamHandler.swift a este target además del principal

class ShareViewController: UIViewController {

    private let appGroupID = "group.com.acelinkhelper.ios"

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        extractAndProcess()
    }

    // MARK: - Extracción

    private func extractAndProcess() {
        guard let item = extensionContext?.inputItems.first as? NSExtensionItem,
              let attachment = item.attachments?.first else {
            finish(error: "No se encontró contenido compartido")
            return
        }

        if attachment.hasItemConformingToTypeIdentifier(UTType.url.identifier) {
            attachment.loadItem(forTypeIdentifier: UTType.url.identifier) { [weak self] data, _ in
                guard let url = data as? URL else {
                    self?.finish(error: "URL no válida")
                    return
                }
                self?.handleURL(url)
            }
        } else if attachment.hasItemConformingToTypeIdentifier(UTType.plainText.identifier) {
            // Fallback: algunos share sheets envían la URL como texto plano
            attachment.loadItem(forTypeIdentifier: UTType.plainText.identifier) { [weak self] data, _ in
                guard let text = data as? String,
                      let url = URL(string: text.trimmingCharacters(in: .whitespacesAndNewlines)) else {
                    self?.finish(error: "El texto no contiene una URL válida")
                    return
                }
                self?.handleURL(url)
            }
        } else {
            finish(error: "Tipo de contenido no compatible")
        }
    }

    // MARK: - Procesamiento

    private func handleURL(_ url: URL) {
        let nasIP = UserDefaults(suiteName: appGroupID)?.string(forKey: "nas_ip") ?? ""

        guard let streamURL = StreamHandler.buildStreamURL(from: url, nasIP: nasIP) else {
            let msg = nasIP.isEmpty
                ? "Abre AcelinkHelper y configura la IP del NAS primero"
                : "El enlace compartido no es un acestream://"
            finish(error: msg)
            return
        }

        guard let vlcURL = URL(string: "vlc://\(streamURL.absoluteString)") else {
            finish(error: "Error construyendo la URL de VLC")
            return
        }

        extensionContext?.open(vlcURL) { [weak self] success in
            if success {
                self?.extensionContext?.completeRequest(returningItems: [], completionHandler: nil)
            } else {
                self?.finish(error: "VLC no está instalado en este dispositivo")
            }
        }
    }

    // MARK: - Cierre

    private func finish(error: String? = nil) {
        DispatchQueue.main.async {
            guard let message = error else {
                self.extensionContext?.completeRequest(returningItems: [], completionHandler: nil)
                return
            }
            let alert = UIAlertController(title: "AcelinkHelper", message: message, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default) { [weak self] _ in
                self?.extensionContext?.completeRequest(returningItems: [], completionHandler: nil)
            })
            self.present(alert, animated: true)
        }
    }
}
