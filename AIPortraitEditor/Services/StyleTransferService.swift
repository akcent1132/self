import Foundation
import CoreImage
import CoreImage.CIFilterBuiltins
import CoreML
import Vision
import UIKit

/// High-level pipeline that performs:
///   1. Style transfer via Core ML (`VNCoreMLRequest`).
///   2. Optional mask-aware compositing using `CIBlendWithMask`.
///   3. Final intensity blend with the original image.
///   4. Tonal adjustments (brightness / contrast / saturation / warmth / vignette).
///
/// The class is **stateless** beyond a shared `CIContext` and a reference to
/// `StyleManager`, which makes it ideal for the service-oriented architecture
/// requested in the spec.
protocol StyleTransferServicing: AnyObject {
    func apply(
        style: Style,
        to input: CIImage,
        mask: CIImage?,
        segment: SegmentMode,
        intensity: Double,
        adjustments: Adjustments
    ) async throws -> CIImage
}

enum StyleTransferError: LocalizedError {
    case missingModel
    case visionFailure(Error)
    case noObservation
    case renderFailure

    var errorDescription: String? {
        switch self {
        case .missingModel:
            return "Selected style model is unavailable."
        case .visionFailure(let error):
            return "Style transfer failed: \(error.localizedDescription)"
        case .noObservation:
            return "Style transfer produced no output."
        case .renderFailure:
            return "Could not render the final image."
        }
    }
}

final class StyleTransferService: StyleTransferServicing {

    private let styleManager: StyleManaging
    private let context: CIContext

    init(styleManager: StyleManaging,
         context: CIContext = CIContext(options: [.useSoftwareRenderer: false])) {
        self.styleManager = styleManager
        self.context = context
    }

    func apply(
        style: Style,
        to input: CIImage,
        mask: CIImage?,
        segment: SegmentMode,
        intensity: Double,
        adjustments: Adjustments
    ) async throws -> CIImage {

        let stylised = try await runStyleTransfer(style: style, on: input)
        let composited = composite(
            original: input,
            stylised: stylised,
            mask: mask,
            segment: segment
        )
        let blended = blend(
            original: input,
            processed: composited,
            intensity: intensity
        )
        return applyAdjustments(blended, adjustments: adjustments)
    }

    // MARK: - Core ML

    private func runStyleTransfer(style: Style, on input: CIImage) async throws -> CIImage {
        guard style.id != Style.none.id else { return input }

        // If the model isn't bundled we fall back to a *demo* path-through
        // image so the UI keeps working end-to-end in the simulator without
        // ML assets shipping in the repo.
        guard let coreModel = try styleManager.model(for: style) else {
            return demoStylisation(of: input, style: style)
        }

        let vnModel: VNCoreMLModel
        do {
            vnModel = try VNCoreMLModel(for: coreModel)
        } catch {
            throw StyleTransferError.visionFailure(error)
        }

        return try await withCheckedThrowingContinuation { continuation in
            let request = VNCoreMLRequest(model: vnModel) { request, error in
                if let error = error {
                    continuation.resume(throwing: StyleTransferError.visionFailure(error))
                    return
                }
                guard
                    let result = request.results?.first as? VNPixelBufferObservation
                else {
                    continuation.resume(throwing: StyleTransferError.noObservation)
                    return
                }
                let output = CIImage(cvPixelBuffer: result.pixelBuffer)
                    .resized(to: input.extent.size)
                continuation.resume(returning: output)
            }
            request.imageCropAndScaleOption = .centerCrop

            let handler = VNImageRequestHandler(ciImage: input, options: [:])
            DispatchQueue.global(qos: .userInitiated).async {
                do {
                    try handler.perform([request])
                } catch {
                    continuation.resume(throwing: StyleTransferError.visionFailure(error))
                }
            }
        }
    }

    /// Cheap pseudo-stylisation used when the actual Core ML model isn't
    /// bundled.  Produces a recognisable artistic effect so demos still feel
    /// alive.  Replace by removing this helper once real models are shipped.
    private func demoStylisation(of input: CIImage, style: Style) -> CIImage {
        let filter = CIFilter.colorMonochrome()
        filter.inputImage = input
        let ci = CIColor(color: UIColor(style.accent))
        filter.color = CIColor(red: ci.red, green: ci.green, blue: ci.blue)
        filter.intensity = 0.55

        let output = filter.outputImage ?? input
        let edges = CIFilter.edges()
        edges.inputImage = input
        edges.intensity = 2.0
        let composite = CIFilter.additionCompositing()
        composite.inputImage = edges.outputImage
        composite.backgroundImage = output
        return composite.outputImage ?? output
    }

    // MARK: - Compositing

    private func composite(
        original: CIImage,
        stylised: CIImage,
        mask: CIImage?,
        segment: SegmentMode
    ) -> CIImage {
        guard let mask = mask, segment != .global else { return stylised }

        let blend = CIFilter.blendWithMask()
        switch segment {
        case .portrait:
            blend.inputImage = stylised
            blend.backgroundImage = original
        case .background:
            blend.inputImage = original
            blend.backgroundImage = stylised
        case .global:
            return stylised
        }
        blend.maskImage = mask
        return blend.outputImage ?? stylised
    }

    // MARK: - Intensity blend

    private func blend(original: CIImage, processed: CIImage, intensity: Double) -> CIImage {
        let clamped = max(0.0, min(1.0, intensity))
        if clamped >= 0.999 { return processed }
        if clamped <= 0.001 { return original }

        let alpha = CIColor(red: 1, green: 1, blue: 1, alpha: CGFloat(clamped))
        let constant = CIFilter.constantColorGenerator()
        constant.color = alpha
        guard let alphaImage = constant.outputImage?.cropped(to: original.extent) else {
            return processed
        }
        let blend = CIFilter.blendWithAlphaMask()
        blend.inputImage = processed
        blend.backgroundImage = original
        blend.maskImage = alphaImage
        return blend.outputImage ?? processed
    }

    // MARK: - Adjustments

    private func applyAdjustments(_ image: CIImage, adjustments: Adjustments) -> CIImage {
        var output = image

        if !(adjustments.brightness == 0 && adjustments.contrast == 1 && adjustments.saturation == 1) {
            let controls = CIFilter.colorControls()
            controls.inputImage = output
            controls.brightness = Float(adjustments.brightness)
            controls.contrast = Float(adjustments.contrast)
            controls.saturation = Float(adjustments.saturation)
            if let result = controls.outputImage { output = result }
        }

        if adjustments.warmth != 0 {
            let temperature = CIFilter.temperatureAndTint()
            temperature.inputImage = output
            temperature.neutral = CIVector(x: 6500, y: 0)
            let warm = 6500 + adjustments.warmth * 2000
            temperature.targetNeutral = CIVector(x: warm, y: 0)
            if let result = temperature.outputImage { output = result }
        }

        if adjustments.vignette > 0 {
            let vignette = CIFilter.vignette()
            vignette.inputImage = output
            vignette.intensity = Float(adjustments.vignette)
            vignette.radius = Float(min(output.extent.width, output.extent.height) * 0.5)
            if let result = vignette.outputImage { output = result }
        }

        return output
    }
}

private extension CIImage {
    func resized(to size: CGSize) -> CIImage {
        guard extent.width > 0, extent.height > 0 else { return self }
        let sx = size.width / extent.width
        let sy = size.height / extent.height
        return transformed(by: CGAffineTransform(scaleX: sx, y: sy))
    }
}
