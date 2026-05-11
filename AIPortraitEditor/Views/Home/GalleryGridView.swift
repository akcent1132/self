import SwiftUI

/// Adaptive grid that lays out gallery thumbnails responsively across phones,
/// pad split-views, and large displays.
struct GalleryGridView: View {
    let assets: [GalleryAsset]
    let onTap: (GalleryAsset) -> Void

    private let columns: [GridItem] = [
        GridItem(.adaptive(minimum: 110, maximum: 180), spacing: AppSpacing.xs)
    ]

    var body: some View {
        LazyVGrid(columns: columns, spacing: AppSpacing.xs) {
            ForEach(assets) { asset in
                Button {
                    onTap(asset)
                } label: {
                    cell(for: asset)
                }
                .buttonStyle(.plain)
            }
        }
    }

    private func cell(for asset: GalleryAsset) -> some View {
        AsyncGalleryImage(asset: asset)
            .aspectRatio(1, contentMode: .fill)
            .frame(maxWidth: .infinity)
            .clipShape(RoundedRectangle(cornerRadius: AppSpacing.cornerRadius, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: AppSpacing.cornerRadius, style: .continuous)
                    .stroke(AppColors.border, lineWidth: 0.5)
            )
            .accessibilityElement()
            .accessibilityLabel(Text("home.gallery.item"))
    }
}
