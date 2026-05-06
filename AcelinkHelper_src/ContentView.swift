import SwiftUI
import CoreImage.CIFilterBuiltins

struct ContentView: View {

    @EnvironmentObject var appState: AppState
    @State private var ipInput: String = ""
    @FocusState private var ipFocused: Bool

    private let bg      = Color(red: 0.051, green: 0.051, blue: 0.102)
    private let accent  = Color(red: 0.42,  green: 0.549, blue: 1.0)

    var body: some View {
        ZStack {
            bg.ignoresSafeArea()

            ScrollView {
                VStack(spacing: 28) {
                    headerSection
                    qrSection
                    configSection
                    statusSection
                }
                .padding(.horizontal, 24)
                .padding(.vertical, 32)
            }
        }
        .preferredColorScheme(.dark)
        .onAppear { ipInput = appState.nasIP }
    }

    // MARK: - Secciones

    private var headerSection: some View {
        VStack(spacing: 6) {
            Text("AcelinkHelper")
                .font(.largeTitle.bold())
                .foregroundColor(.white)
            Text("Protocolo acestream:// activo")
                .font(.subheadline)
                .foregroundColor(accent)
        }
    }

    private var qrSection: some View {
        VStack(spacing: 12) {
            Text("IP del dispositivo")
                .font(.caption)
                .foregroundColor(.gray)

            Text(appState.deviceIP)
                .font(.system(.body, design: .monospaced))
                .foregroundColor(.white)

            if let qr = qrImage(for: "http://\(appState.deviceIP):8765") {
                Image(uiImage: qr)
                    .interpolation(.none)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 160, height: 160)
                    .cornerRadius(8)
            }

            Text("Escanea desde Mac o PC para enviar streams al iPhone")
                .font(.caption2)
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
        }
        .padding(20)
        .background(Color.white.opacity(0.05))
        .cornerRadius(16)
    }

    private var configSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("IP del servidor NAS")
                .font(.caption)
                .foregroundColor(.gray)

            HStack(spacing: 10) {
                TextField("192.168.1.100", text: $ipInput)
                    .keyboardType(.decimalPad)
                    .focused($ipFocused)
                    .font(.system(.body, design: .monospaced))
                    .padding(12)
                    .background(Color.white.opacity(0.08))
                    .cornerRadius(10)
                    .foregroundColor(.white)

                Button {
                    appState.nasIP = ipInput
                    ipFocused = false
                    appState.statusMessage = "IP guardada correctamente"
                    appState.isError = false
                } label: {
                    Text("Guardar")
                        .fontWeight(.semibold)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 12)
                        .background(accent)
                        .cornerRadius(10)
                        .foregroundColor(.white)
                }
            }
        }
    }

    private var statusSection: some View {
        Group {
            if !appState.statusMessage.isEmpty {
                Text(appState.statusMessage)
                    .font(.subheadline)
                    .foregroundColor(appState.isError ? .red : .green)
                    .multilineTextAlignment(.center)
                    .padding(.top, 4)
            }
        }
    }

    // MARK: - QR helper

    private func qrImage(for string: String) -> UIImage? {
        let context = CIContext()
        let filter  = CIFilter.qrCodeGenerator()
        filter.message = Data(string.utf8)
        filter.correctionLevel = "M"
        guard let ciImage = filter.outputImage else { return nil }
        let scaled = ciImage.transformed(by: CGAffineTransform(scaleX: 10, y: 10))
        guard let cgImage = context.createCGImage(scaled, from: scaled.extent) else { return nil }
        return UIImage(cgImage: cgImage)
    }
}
