import SwiftUI

@main
struct AIPortraitEditorApp: App {
    @StateObject private var settings = SettingsViewModel()

    var body: some Scene {
        WindowGroup {
            RootView()
                .preferredColorScheme(settings.appearance.colorScheme)
                .environmentObject(settings)
                .dynamicTypeSize(...DynamicTypeSize.accessibility3)
        }
    }
}
