import SwiftUI

@main
struct Geometry: App {
    @State private var settings = Settings()
    
    var body: some Scene {
        WindowGroup {
            Contents()
                .environment(\.settings, settings)
        }
        .windowStyle(.hiddenTitleBar)
    }
}
