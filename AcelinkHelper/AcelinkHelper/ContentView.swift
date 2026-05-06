import SwiftUI
import UIKit

// MARK: - Custom IP numpad (UIKit)

private class IPNumpadView: UIInputView {
    var onInsert: ((String) -> Void)?
    var onDelete: (() -> Void)?

    init() {
        super.init(frame: CGRect(x: 0, y: 0, width: 0, height: 216), inputViewStyle: .keyboard)
        autoresizingMask = [.flexibleWidth]
        setup()
    }
    required init?(coder: NSCoder) { fatalError() }

    private func setup() {
        let rows: [[String]] = [["1","2","3"],["4","5","6"],["7","8","9"],[".","0","⌫"]]
        let vStack = UIStackView()
        vStack.axis = .vertical
        vStack.distribution = .fillEqually
        vStack.spacing = 8
        vStack.translatesAutoresizingMaskIntoConstraints = false
        addSubview(vStack)
        NSLayoutConstraint.activate([
            vStack.topAnchor.constraint(equalTo: topAnchor, constant: 8),
            vStack.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 8),
            vStack.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -8),
            vStack.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -8)
        ])
        for row in rows {
            let hStack = UIStackView()
            hStack.axis = .horizontal
            hStack.distribution = .fillEqually
            hStack.spacing = 8
            for key in row {
                let btn = UIButton(type: .system)
                btn.setTitle(key, for: .normal)
                btn.titleLabel?.font = .systemFont(ofSize: 22)
                btn.backgroundColor = key == "⌫" ? .systemGray3 : .systemBackground
                btn.tintColor = .label
                btn.layer.cornerRadius = 8
                btn.layer.masksToBounds = true
                btn.tag = key == "⌫" ? -1 : 0
                btn.addTarget(self, action: #selector(tapped(_:)), for: .touchUpInside)
                hStack.addArrangedSubview(btn)
            }
            vStack.addArrangedSubview(hStack)
        }
    }

    @objc private func tapped(_ sender: UIButton) {
        if sender.tag == -1 { onDelete?() } else { onInsert?(sender.title(for: .normal) ?? "") }
    }
}

// MARK: - IP text field wrapper

private struct IPTextField: UIViewRepresentable {
    @Binding var text: String
    let placeholder: String

    func makeCoordinator() -> Coordinator { Coordinator($text) }

    func makeUIView(context: Context) -> UITextField {
        let tf = UITextField()
        tf.placeholder = placeholder
        tf.borderStyle = .roundedRect
        tf.font = .preferredFont(forTextStyle: .subheadline)
        tf.autocorrectionType = .no
        tf.spellCheckingType = .no
        tf.delegate = context.coordinator
        tf.addTarget(context.coordinator, action: #selector(Coordinator.changed(_:)), for: .editingChanged)

        let numpad = IPNumpadView()
        numpad.onInsert = { [weak tf] char in tf?.insertText(char) }
        numpad.onDelete = { [weak tf] in tf?.deleteBackward() }
        tf.inputView = numpad
        tf.inputAccessoryView = UIView(frame: .zero)
        return tf
    }

    func updateUIView(_ tf: UITextField, context: Context) {
        if tf.text != text { tf.text = text }
    }

    class Coordinator: NSObject, UITextFieldDelegate {
        @Binding var text: String
        init(_ text: Binding<String>) { _text = text }
        @objc func changed(_ tf: UITextField) { text = tf.text ?? "" }
    }
}

// MARK: - Share sheet

private struct ShareSheet: UIViewControllerRepresentable {
    let items: [Any]

    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: items, applicationActivities: nil)
    }
    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}

// MARK: - Main view

struct ContentView: View {
    @EnvironmentObject var appState: AppState
    @State private var showShareSheet = false

    private let backgroundColor = Color(red: 13/255, green: 13/255, blue: 26/255)
    private let accentColor = Color(red: 107/255, green: 140/255, blue: 255/255)

    var body: some View {
        ZStack {
            backgroundColor.ignoresSafeArea()

            ScrollView {
                VStack(spacing: 20) {
                    Text("AcelinkHelper")
                        .font(.title2.bold())
                        .foregroundColor(.white)

                    if appState.pendingStreamURL != nil {
                        streamActionPanel
                    }

                    nasConfigPanel

                    if !appState.statusMessage.isEmpty {
                        Text(appState.statusMessage)
                            .foregroundColor(appState.isError ? .red : .green)
                            .font(.caption)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                    }
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 48)
            }
            .scrollDismissesKeyboard(.interactively)
        }
        .preferredColorScheme(.dark)
        .sheet(isPresented: $showShareSheet) {
            if let fileURL = appState.m3uFileURL {
                ShareSheet(items: [fileURL])
            }
        }
    }

    // MARK: - Stream action panel

    private var streamActionPanel: some View {
        VStack(spacing: 12) {
            HStack(spacing: 8) {
                Image(systemName: "dot.radiowaves.left.and.right")
                    .foregroundColor(accentColor)
                Text("Stream listo")
                    .foregroundColor(.white)
                    .font(.subheadline.weight(.semibold))
            }

            Button(action: { appState.openInLocalVLC() }) {
                Label("Abrir en VLC local", systemImage: "play.circle.fill")
                    .font(.subheadline.weight(.semibold))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background(accentColor)
                    .cornerRadius(10)
            }

            Button(action: { showShareSheet = true }) {
                Label("Enviar a otro dispositivo", systemImage: "wifi")
                    .font(.subheadline.weight(.semibold))
                    .foregroundColor(accentColor)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background(accentColor.opacity(0.12))
                    .cornerRadius(10)
                    .overlay(RoundedRectangle(cornerRadius: 10).stroke(accentColor.opacity(0.4), lineWidth: 1))
            }
        }
        .padding(16)
        .background(Color.white.opacity(0.07))
        .cornerRadius(14)
        .padding(.horizontal, 24)
    }

    // MARK: - NAS config panel

    private var nasConfigPanel: some View {
        VStack(spacing: 8) {
            Text("IP del NAS (AceStream)")
                .foregroundColor(.white)
                .font(.subheadline.weight(.medium))

            IPTextField(text: $appState.nasIP, placeholder: "Ej: 192.168.1.100")
                .frame(height: 36)

            Button(action: { appState.saveNASIP() }) {
                Text("Guardar")
                    .font(.subheadline.weight(.semibold))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 10)
                    .background(accentColor)
                    .cornerRadius(8)
            }
        }
        .padding(12)
        .background(Color.white.opacity(0.05))
        .cornerRadius(12)
        .padding(.horizontal, 24)
    }
}

#Preview {
    ContentView()
        .environmentObject(AppState())
}
