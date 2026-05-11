import SwiftUI
import Photos
import Factory

/// Loads a thumbnail for a `GalleryAsset` lazily, falling back to a placeholder
/// asset shipped with the app.
struct AsyncGalleryImage: View {
    let asset: GalleryAsset
    var targetSize: CGSize = CGSize(width: 400, height: 400)

    @Injected(\.photoLibraryService) private var photoLibrary
    @State private var image: UIImage?

    var body: some View {
        ZStack {
            if let image {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFill()
            } else if let placeholder = asset.placeholderName, let img = UIImage(named: placeholder) {
                Image(uiImage: img).resizable().scaledToFill()
            } else {
                LinearGradient(
                    colors: [AppColors.backgroundSecondary, AppColors.surface],
                    startPoint: .topLeading, endPoint: .bottomTrailing
                )
                ProgressView()
            }
        }
        .task(id: asset.id) {
            image = await photoLibrary.loadImage(for: asset, targetSize: targetSize, contentMode: .aspectFill)
        }
    }
}
