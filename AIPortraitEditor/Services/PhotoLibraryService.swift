import Foundation
import Photos
import UIKit

/// Fetches recent photos from the device library for the Home/Gallery grid.
/// Falls back to bundled placeholders when access has not been granted yet.
protocol PhotoLibraryServicing: AnyObject {
    func requestAuthorization() async -> PHAuthorizationStatus
    func recentPhotos(limit: Int) async -> [GalleryAsset]
    func loadImage(for asset: GalleryAsset,
                   targetSize: CGSize,
                   contentMode: PHImageContentMode) async -> UIImage?
}

final class PhotoLibraryService: PhotoLibraryServicing {

    private let imageManager = PHCachingImageManager()

    func requestAuthorization() async -> PHAuthorizationStatus {
        await withCheckedContinuation { cont in
            PHPhotoLibrary.requestAuthorization(for: .readWrite) { status in
                cont.resume(returning: status)
            }
        }
    }

    func recentPhotos(limit: Int) async -> [GalleryAsset] {
        let status = PHPhotoLibrary.authorizationStatus(for: .readWrite)
        guard status == .authorized || status == .limited else {
            return GalleryAsset.placeholders
        }

        return await withCheckedContinuation { cont in
            DispatchQueue.global(qos: .userInitiated).async {
                let options = PHFetchOptions()
                options.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
                options.fetchLimit = limit
                let result = PHAsset.fetchAssets(with: .image, options: options)

                var items: [GalleryAsset] = []
                result.enumerateObjects { asset, _, _ in
                    items.append(
                        GalleryAsset(
                            id: asset.localIdentifier,
                            assetIdentifier: asset.localIdentifier,
                            placeholderName: nil,
                            createdAt: asset.creationDate
                        )
                    )
                }
                cont.resume(returning: items.isEmpty ? GalleryAsset.placeholders : items)
            }
        }
    }

    func loadImage(for asset: GalleryAsset,
                   targetSize: CGSize,
                   contentMode: PHImageContentMode = .aspectFill) async -> UIImage? {
        guard let identifier = asset.assetIdentifier else {
            if let name = asset.placeholderName {
                return UIImage(named: name)
            }
            return nil
        }

        return await withCheckedContinuation { cont in
            let fetch = PHAsset.fetchAssets(withLocalIdentifiers: [identifier], options: nil)
            guard let phAsset = fetch.firstObject else {
                cont.resume(returning: nil)
                return
            }
            let options = PHImageRequestOptions()
            options.deliveryMode = .highQualityFormat
            options.resizeMode = .exact
            options.isNetworkAccessAllowed = true
            imageManager.requestImage(
                for: phAsset,
                targetSize: targetSize,
                contentMode: contentMode,
                options: options
            ) { image, _ in
                cont.resume(returning: image)
            }
        }
    }
}
