import SwiftUI

@main
struct AcelinkHelperTVApp: App {
    @StateObject private var appState = TVAppState()

    var body: some Scene {
        WindowGroup {
            TVContentView()
                .environmentObject(appState)
                .onAppear { appState.startServer() }
        }
    }
}
