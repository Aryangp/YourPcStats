import SwiftUI

@main
struct YourPcStatsApp: App {
    @StateObject private var monitor = SystemMonitor()

    var body: some Scene {
        MenuBarExtra {
            DashboardView(monitor: monitor)
        } label: {
            if let image = monitor.menuBarImage {
                Image(nsImage: image)
            } else {
                Image(systemName: "gauge.with.needle")
            }
        }
        .menuBarExtraStyle(.window)
    }
}
