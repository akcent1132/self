import SwiftUI

struct EditorView: View {
    @StateObject private var viewModel = EditorViewModel()
    @Environment(\.dismiss) private var dismiss
    @State private var didLoad = false

    let initialImage: UIImage

    var body: some View {
        ZStack {
            AppColors.background.ignoresSafeArea()

            VStack(spacing: 0) {
                preview
                controls
            }

            overlayIfNeeded
        }
        .toolbar(.hidden, for: .navigationBar)
        .safeAreaInset(edge: .top) { toolbar }
        .onAppear {
            guard !didLoad else { return }
            didLoad = true
            viewModel.load(image: initialImage)
        }
        .sheet(isPresented: $viewModel.showAdjustments) {
            AdjustmentsSheet(
                adjustments: Binding(
                    get: { viewModel.state.adjustments },
                    set: { viewModel.updateAdjustments($0) }
                ),
                onReset: viewModel.resetAdjustments
            )
            .presentationDetents([.medium, .large])
            .presentationDragIndicator(.visible)
        }
        .sheet(isPresented: $viewModel.showShareSheet) {
            if let image = viewModel.shareImage() {
                ShareSheet(items: [image])
            }
        }
        .alert(
            Text("editor.error.title"),
            isPresented: Binding(
                get: { viewModel.lastError != nil },
                set: { if !$0 { viewModel.lastError = nil } }
            )
        ) {
            Button(role: .cancel) { viewModel.lastError = nil } label: { Text("common.ok") }
        } message: {
            if let msg = viewModel.lastError { Text(msg) }
        }
    }

    // MARK: - Toolbar

    private var toolbar: some View {
        HStack(spacing: AppSpacing.sm) {
            Button { dismiss() } label: {
                Image(systemName: "chevron.left")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundStyle(AppColors.textPrimary)
                    .frame(width: 40, height: 40)
                    .background(Circle().fill(AppColors.surface))
            }
            .accessibilityLabel(Text("common.back"))

            Spacer()

            Text("editor.title")
                .font(AppTypography.headline)
                .foregroundStyle(AppColors.textPrimary)

            Spacer()

            Button { viewModel.showShareSheet = true } label: {
                Image(systemName: "square.and.arrow.up")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundStyle(AppColors.textPrimary)
                    .frame(width: 40, height: 40)
                    .background(Circle().fill(AppColors.surface))
            }
            .accessibilityLabel(Text("editor.action.share"))
        }
        .padding(.horizontal, AppSpacing.md)
        .padding(.top, AppSpacing.xs)
    }

    // MARK: - Preview canvas

    private var preview: some View {
        GeometryReader { proxy in
            ZStack {
                if let rendered = viewModel.renderedImage {
                    Image(uiImage: rendered)
                        .resizable()
                        .scaledToFit()
                        .frame(width: proxy.size.width, height: proxy.size.height)
                        .transition(.opacity)
                } else if let source = viewModel.sourceImage {
                    Image(uiImage: source)
                        .resizable()
                        .scaledToFit()
                        .frame(width: proxy.size.width, height: proxy.size.height)
                        .opacity(0.85)
                } else {
                    Color.clear
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(AppColors.backgroundSecondary)
            .clipShape(RoundedRectangle(cornerRadius: AppSpacing.cornerRadiusLarge, style: .continuous))
            .padding(.horizontal, AppSpacing.md)
            .padding(.top, AppSpacing.xs)
        }
    }

    // MARK: - Controls

    private var controls: some View {
        VStack(spacing: AppSpacing.md) {
            SegmentToggleView(
                selection: Binding(
                    get: { viewModel.state.segmentMode },
                    set: { viewModel.select(segment: $0) }
                ),
                hasSegmentation: viewModel.state.hasSegmentation
            )
            .padding(.horizontal, AppSpacing.md)

            IntensitySliderView(
                value: Binding(
                    get: { viewModel.state.intensity },
                    set: { viewModel.sliderChanged(to: $0) }
                )
            )
            .padding(.horizontal, AppSpacing.md)

            StyleSelectorView(
                styles: viewModel.availableStyles,
                selectedID: viewModel.state.style.id,
                onSelect: { viewModel.select(style: $0) }
            )

            actionRow
                .padding(.horizontal, AppSpacing.md)
                .padding(.bottom, AppSpacing.md)
        }
        .padding(.top, AppSpacing.md)
        .background(
            AppColors.background
                .shadow(color: .black.opacity(0.12), radius: 20, x: 0, y: -8)
                .mask(Rectangle().padding(.top, -20))
        )
    }

    private var actionRow: some View {
        HStack(spacing: AppSpacing.sm) {
            Button {
                viewModel.showAdjustments = true
            } label: {
                Label("editor.action.adjust", systemImage: "slider.horizontal.3")
                    .font(AppTypography.headline)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, AppSpacing.sm)
            }
            .buttonStyle(.borderedProminent)
            .tint(AppColors.surface)
            .foregroundStyle(AppColors.textPrimary)

            Button {
                viewModel.saveToPhotos()
            } label: {
                Label("editor.action.save", systemImage: "checkmark.circle.fill")
                    .font(AppTypography.headline)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, AppSpacing.sm)
            }
            .buttonStyle(.borderedProminent)
            .tint(AppColors.accent)
        }
    }

    // MARK: - Overlays

    @ViewBuilder
    private var overlayIfNeeded: some View {
        switch viewModel.phase {
        case .analyzing:
            LoadingOverlay(titleKey: "editor.phase.analyzing", animationName: "analyzing")
        case .applyingStyle:
            if viewModel.renderedImage == nil {
                LoadingOverlay(titleKey: "editor.phase.styling", animationName: "applying-style")
            }
        case .loadingImage:
            LoadingOverlay(titleKey: "editor.phase.loading", animationName: "analyzing")
        default:
            EmptyView()
        }
    }
}

#Preview {
    EditorView(initialImage: UIImage(systemName: "photo") ?? UIImage())
}
