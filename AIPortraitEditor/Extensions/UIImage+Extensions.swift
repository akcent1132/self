import UIKit
import CoreImage

extension UIImage {
    /// Normalises EXIF orientation so the underlying `CGImage` and downstream
    /// `CIImage` are aligned with what the user sees.
    func orientedUp() -> UIImage {
        guard imageOrientation != .up else { return self }
        UIGraphicsBeginImageContextWithOptions(size, false, scale)
        defer { UIGraphicsEndImageContext() }
        draw(in: CGRect(origin: .zero, size: size))
        return UIGraphicsGetImageFromCurrentImageContext() ?? self
    }

    /// Returns a `CIImage` that respects the user-visible orientation.
    func ciImagePreservingOrientation() -> CIImage? {
        if let ciImage = ciImage { return ciImage }
        guard let cgImage = cgImage else { return nil }
        return CIImage(cgImage: cgImage).oriented(forExifOrientation: Int32(imageOrientation.exifValue))
    }

    /// Down-samples while preserving aspect ratio for fast on-canvas preview.
    func downsampled(to maxDimension: CGFloat) -> UIImage {
        let longest = max(size.width, size.height)
        guard longest > maxDimension else { return self }
        let ratio = maxDimension / longest
        let newSize = CGSize(width: size.width * ratio, height: size.height * ratio)
        let renderer = UIGraphicsImageRenderer(size: newSize)
        return renderer.image { _ in
            draw(in: CGRect(origin: .zero, size: newSize))
        }
    }
}

private extension UIImage.Orientation {
    var exifValue: Int {
        switch self {
        case .up: return 1
        case .down: return 3
        case .left: return 8
        case .right: return 6
        case .upMirrored: return 2
        case .downMirrored: return 4
        case .leftMirrored: return 5
        case .rightMirrored: return 7
        @unknown default: return 1
        }
    }
}
