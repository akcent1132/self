import SwiftUI

/// Tab-bar root that hosts the three primary destinations.  The Editor is
/// pushed from Home so it can claim the full screen with its custom toolbar.
struct RootView: View {
    @State private var selection: Tab = .home

    enum Tab: Hashable { case home, feed, settings }

    var body: some View {
        TabView(selection: $selection) {
            HomeView()
                .tabItem {
                    Label("tab.home", systemImage: "house.fill")
                }
                .tag(Tab.home)

            FeedView()
                .tabItem {
                    Label("tab.feed", systemImage: "sparkles.rectangle.stack")
                }
                .tag(Tab.feed)

            NavigationStack { SettingsView() }
                .tabItem {
                    Label("tab.settings", systemImage: "gearshape.fill")
                }
                .tag(Tab.settings)
        }
        .tint(AppColors.accent)
    }
}

#Preview {
    RootView()
}
