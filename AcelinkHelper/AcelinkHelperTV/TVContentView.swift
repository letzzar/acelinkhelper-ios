import SwiftUI
import CoreImage.CIFilterBuiltins

struct TVContentView: View {
    @EnvironmentObject var appState: TVAppState

    private let bg     = Color(red: 13/255,  green: 13/255,  blue: 26/255)
    private let accent = Color(red: 107/255, green: 140/255, blue: 255/255)

    var body: some View {
        ZStack {
            bg.ignoresSafeArea()

            HStack(spacing: 80) {
                qrPanel
                infoPanel
            }
            .padding(60)
        }
        .preferredColorScheme(.dark)
    }

    // MARK: - QR panel

    private var qrPanel: some View {
        VStack(spacing: 24) {
            if let img = qrImage {
                Image(uiImage: img)
                    .interpolation(.none)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 300, height: 300)
                    .background(Color.white)
                    .cornerRadius(16)
            }

            VStack(spacing: 6) {
                Text("Escanea desde tu móvil")
                    .font(.title3)
                    .foregroundColor(.gray)

                Text("http://\(appState.deviceIP):8765")
                    .font(.title2.monospaced().bold())
                    .foregroundColor(accent)
            }
        }
    }

    // MARK: - Info panel

    private var infoPanel: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("AcelinkHelper TV")
                .font(.largeTitle.bold())
                .foregroundColor(.white)

            Rectangle()
                .frame(height: 1)
                .foregroundColor(.white.opacity(0.15))

            Label {
                Text("Servidor activo · puerto 8765")
                    .foregroundColor(.white.opacity(0.75))
            } icon: {
                Image(systemName: "wifi")
                    .foregroundColor(accent)
            }

            Label {
                if appState.nasIP.isEmpty {
                    Text("IP del NAS no configurada")
                        .foregroundColor(.orange)
                } else {
                    Text("NAS: \(appState.nasIP)")
                        .foregroundColor(.green)
                }
            } icon: {
                Image(systemName: appState.nasIP.isEmpty ? "exclamationmark.circle" : "checkmark.circle.fill")
                    .foregroundColor(appState.nasIP.isEmpty ? .orange : .green)
            }

            if !appState.statusMessage.isEmpty {
                Text(appState.statusMessage)
                    .font(.callout)
                    .foregroundColor(appState.isError ? .red : .green)
                    .transition(.opacity)
            }

            Spacer()

            Text("Introduce un enlace acestream:// en la\ninterfaz web para reproducir en VLC.")
                .font(.callout)
                .foregroundColor(.gray)
                .lineSpacing(5)
        }
        .padding(.vertical, 20)
        .frame(maxWidth: 460, alignment: .leading)
    }

    // MARK: - QR generation

    private var qrImage: UIImage? {
        let string = "http://\(appState.deviceIP):8765"
        let context = CIContext()
        let filter = CIFilter.qrCodeGenerator()
        filter.message = Data(string.utf8)
        filter.correctionLevel = "M"
        guard let output = filter.outputImage else { return nil }
        let scale = 600.0 / output.extent.width
        let scaled = output.transformed(by: CGAffineTransform(scaleX: scale, y: scale))
        guard let cgImage = context.createCGImage(scaled, from: scaled.extent) else { return nil }
        return UIImage(cgImage: cgImage)
    }
}
