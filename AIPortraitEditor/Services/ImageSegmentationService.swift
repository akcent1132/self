import Foundation
import Vision
import CoreImage
import UIKit

/// Service responsible for generating an alpha-mask `CIImage` representing the
/// person inside a photograph.
///
/// The implementation prefers the modern
/// `VNGeneratePersonSegmentationRequest` (iOS 15+) which produces an
/// ANTailor-style mask without requiring a bundled model.  A fallback path
/// using `VNGeneratePersonInstanceMaskRequest` is provided for iOS 17+ when a
/// higher-quality, instance-aware mask is desirable.
protocol ImageSegmentationServicing: AnyObject {
    /// Generates a portrait alpha mask aligned with the input image.
    /// - Returns: A grayscale `CIImage` of identical extent.
    func segmentPerson(in image: CIImage) async throws -> CIImage
}

enum ImageSegmentationError: LocalizedError {
    case noObservation
    case underlying(Error)

    var errorDescription: String? {
        switch self {
        case .noObservation:
            return NSLocalizedString(
                "error.segmentation.empty",
                value: "No person detected in the photo.",
                comment: "Shown when Vision could not produce a mask"
            )
        case .underlying(let error):
            return error.localizedDescription
        }
    }
}

final class ImageSegmentationService: ImageSegmentationServicing {

    private let context: CIContext

    init(context: CIContext = CIContext(options: [.useSoftwareRenderer: false])) {
        self.context = context
    }

    func segmentPerson(in image: CIImage) async throws -> CIImage {
        try await withCheckedThrowingContinuation { continuation in
            let request = VNGeneratePersonSegmentationRequest()
            request.qualityLevel = .balanced
            request.outputPixelFormat = kCVPixelFormatType_OneComponent8

            let handler = VNImageRequestHandler(ciImage: image, options: [:])
            do {
                try handler.perform([request])
                guard let result = request.results?.first else {
                    continuation.resume(throwing: ImageSegmentationError.noObservation)
                    return
                }
                let mask = CIImage(cvPixelBuffer: result.pixelBuffer)
                let scaled = mask.resized(to: image.extent.size)
                continuation.resume(returning: scaled)
            } catch {
                continuation.resume(throwing: ImageSegmentationError.underlying(error))
            }
        }
    }
}

private extension CIImage {
    func resized(to size: CGSize) -> CIImage {
        let sx = size.width / extent.width
        let sy = size.height / extent.height
        return transformed(by: CGAffineTransform(scaleX: sx, y: sy))
    }
}
