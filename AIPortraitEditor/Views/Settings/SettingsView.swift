import SwiftUI

struct SettingsView: View {
    @StateObject private var viewModel = SettingsViewModel()

    var body: some View {
        Form {
            Section {
                Picker(selection: $viewModel.appearance) {
                    ForEach(AppAppearance.allCases) { appearance in
                        Text(appearance.titleKey).tag(appearance)
                    }
                } label: {
                    Label("settings.appearance", systemImage: "circle.lefthalf.filled")
                }
            } header: {
                Text("settings.section.display")
            }

            Section {
                Toggle(isOn: $viewModel.hapticsEnabled) {
                    Label("settings.haptics", systemImage: "iphone.radiowaves.left.and.right")
                }
                Toggle(isOn: $viewModel.saveOriginal) {
                    Label("settings.save.original", systemImage: "square.stack.3d.up")
                }
                Toggle(isOn: $viewModel.highQualityRender) {
                    Label("settings.quality", systemImage: "sparkles")
                }
            } header: {
                Text("settings.section.editor")
            }

            Section {
                Link(destination: URL(string: "https://www.apple.com/legal/privacy/")!) {
                    Label("settings.privacy", systemImage: "lock.shield")
                }
                Link(destination: URL(string: "https://www.apple.com/legal/")!) {
                    Label("settings.terms", systemImage: "doc.text")
                }
            } header: {
                Text("settings.section.legal")
            }

            Section {
                HStack {
                    Label("settings.version", systemImage: "info.circle")
                    Spacer()
                    Text(viewModel.appVersion)
                        .foregroundStyle(AppColors.textSecondary)
                        .monospacedDigit()
                }
            } header: {
                Text("settings.section.about")
            }
        }
        .scrollContentBackground(.hidden)
        .background(AppColors.background.ignoresSafeArea())
        .navigationTitle(Text("settings.title"))
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    NavigationStack { SettingsView() }
}
