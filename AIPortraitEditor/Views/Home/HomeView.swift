import SwiftUI
import PhotosUI
import Factory

struct HomeView: View {
    @StateObject private var viewModel = HomeViewModel()
    @Injected(\.photoLibraryService) private var photoLibrary

    @State private var showPicker = false
    @State private var pickedImage: UIImage?
    @State private var pushEditor = false

    var body: some View {
        NavigationStack {
            ZStack {
                AppColors.background.ignoresSafeArea()

                ScrollView {
                    VStack(alignment: .leading, spacing: AppSpacing.lg) {
                        header
                        primaryAction
                        recentSection
                    }
                    .padding(.horizontal, AppSpacing.md)
                    .padding(.bottom, AppSpacing.xxl)
                }
                .refreshable { await viewModel.refresh() }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("home.title")
                        .font(AppTypography.title)
                        .foregroundStyle(AppColors.textPrimary)
                }
                ToolbarItem(placement: .topBarTrailing) {
                    NavigationLink(destination: SettingsView()) {
                        Image(systemName: "gearshape")
                            .foregroundStyle(AppColors.textPrimary)
                    }
                    .accessibilityLabel(Text("home.action.settings"))
                }
            }
            .task { await viewModel.onAppear() }
            .sheet(isPresented: $showPicker) {
                PhotoPicker(isPresented: $showPicker) { image in
                    pickedImage = image
                    pushEditor = true
                }
            }
            .navigationDestination(isPresented: $pushEditor) {
                if let img = pickedImage {
                    EditorView(initialImage: img)
                }
            }
        }
        .tint(AppColors.accent)
    }

    // MARK: - Sections

    private var header: some View {
        VStack(alignment: .leading, spacing: AppSpacing.xxs) {
            Text("home.greeting")
                .font(AppTypography.largeTitle)
                .foregroundStyle(AppColors.textPrimary)
            Text("home.subtitle")
                .font(AppTypography.body)
                .foregroundStyle(AppColors.textSecondary)
        }
        .padding(.top, AppSpacing.sm)
    }

    private var primaryAction: some View {
        Button {
            showPicker = true
        } label: {
            HStack(spacing: AppSpacing.sm) {
                Image(systemName: "wand.and.stars")
                    .imageScale(.large)
                Text("home.action.pickPhoto")
                    .font(AppTypography.headline)
                Spacer()
                Image(systemName: "arrow.right")
            }
            .padding(AppSpacing.md)
            .frame(maxWidth: .infinity)
            .background(
                LinearGradient(
                    colors: [AppColors.accent, AppColors.accentSecondary],
                    startPoint: .leading, endPoint: .trailing
                )
            )
            .foregroundStyle(.white)
            .clipShape(RoundedRectangle(cornerRadius: AppSpacing.cornerRadius, style: .continuous))
        }
        .buttonStyle(.plain)
        .accessibilityHint(Text("home.action.pickPhoto.hint"))
    }

    private var recentSection: some View {
        VStack(alignment: .leading, spacing: AppSpacing.sm) {
            HStack {
                Text("home.section.recent")
                    .font(AppTypography.title)
                    .foregroundStyle(AppColors.textPrimary)
                Spacer()
                if viewModel.isLoading {
                    ProgressView().controlSize(.small)
                }
            }
            GalleryGridView(assets: viewModel.assets) { asset in
                Task { await openInEditor(asset) }
            }
        }
    }

    private func openInEditor(_ asset: GalleryAsset) async {
        let target = CGSize(width: 2048, height: 2048)
        if let img = await photoLibrary.loadImage(for: asset, targetSize: target, contentMode: .aspectFit) {
            await MainActor.run {
                pickedImage = img
                pushEditor = true
            }
        }
    }
}

#Preview {
    HomeView()
}
