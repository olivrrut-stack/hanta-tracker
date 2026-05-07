import SwiftUI

@main
struct HantaTrackerApp: App {
    @AppStorage("disclaimer_accepted") private var disclaimerAccepted = false

    var body: some Scene {
        WindowGroup {
            if disclaimerAccepted {
                ContentView()
                    .preferredColorScheme(.dark)
            } else {
                DisclaimerView(accepted: $disclaimerAccepted)
                    .preferredColorScheme(.dark)
            }
        }
    }
}
