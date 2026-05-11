import UIKit
import CoreImage
import Photos

/// Saves rendered images to the user's Photo Library and/or returns share
/// payloads suitable for `UIActivityViewController`.
protocol ImageExportServicing: AnyObject {
    func saveToPhotos(_ image: UIImage) async throws
    func render(_ ciImage: CIImage) -> UIImage?
}

enum ImageExportError: LocalizedError {
    case permissionDenied
    case renderingFailed
    case writingFailed(Error)

    var errorDescription: String? {
        switch self {
        case .permissionDenied:
            return "Photo Library access was denied."
        case .renderingFailed:
            return "Could not render the final image."
        case .writingFailed(let error):
            return "Saving failed: \(error.localizedDescription)"
        }
    }
}

final class ImageExportService: ImageExportServicing {

    private let context: CIContext

    init(context: CIContext = CIContext(options: [.useSoftwareRenderer: false])) {
        self.context = context
    }

    func render(_ ciImage: CIImage) -> UIImage? {
        guard let cgImage = context.createCGImage(ciImage, from: ciImage.extent) else {
            return nil
        }
        return UIImage(cgImage: cgImage)
    }

    func saveToPhotos(_ image: UIImage) async throws {
        let status = await Self.requestAuthorization()
        guard status == .authorized || status == .limited else {
            throw ImageExportError.permissionDenied
        }
        try await withCheckedThrowingContinuation { (cont: CheckedContinuation<Void, Error>) in
            PHPhotoLibrary.shared().performChanges {
                PHAssetChangeRequest.creationRequestForAsset(from: image)
            } completionHandler: { success, error in
                if success {
                    cont.resume()
                } else if let error = error {
                    cont.resume(throwing: ImageExportError.writingFailed(error))
                } else {
                    cont.resume(throwing: ImageExportError.renderingFailed)
                }
            }
        }
    }

    private static func requestAuthorization() async -> PHAuthorizationStatus {
        await withCheckedContinuation { cont in
            PHPhotoLibrary.requestAuthorization(for: .addOnly) { status in
                cont.resume(returning: status)
            }
        }
    }
}
