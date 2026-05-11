import Foundation
import SwiftUI
import CoreImage
import UIKit
import Factory

@MainActor
final class EditorViewModel: ObservableObject {

    @Injected(\.styleManager) private var styleManager
    @Injected(\.segmentationService) private var segmentation
    @Injected(\.styleTransferService) private var styleTransfer
    @Injected(\.hapticsService) private var haptics
    @Injected(\.imageExportService) private var exporter

    // MARK: - Public state

    @Published private(set) var sourceImage: UIImage?
    @Published private(set) var renderedImage: UIImage?
    @Published private(set) var phase: EditorPhase = .idle
    @Published var state: EditorState = EditorState()
    @Published var showAdjustments: Bool = false
    @Published var showShareSheet: Bool = false
    @Published var lastError: String?

    var availableStyles: [Style] { styleManager.availableStyles }

    // MARK: - Private state

    private var sourceCIImage: CIImage?
    private var maskCIImage: CIImage?
    private var renderTask: Task<Void, Never>?
    private var lastSliderValue: Double = 0.8

    // MARK: - Public API

    func load(image: UIImage) {
        renderTask?.cancel()
        renderedImage = nil
        maskCIImage = nil
        state.hasSegmentation = false
        phase = .loadingImage

        let normalized = image.orientedUp().downsampled(to: 1600)
        sourceImage = normalized
        sourceCIImage = normalized.ciImagePreservingOrientation()

        Task { [weak self] in
            await self?.prepareSegmentation()
            await self?.render()
        }
    }

    func select(style: Style) {
        guard style != state.style else { return }
        haptics.selection()
        state.style = style
        scheduleRender()
    }

    func select(segment: SegmentMode) {
        guard segment != state.segmentMode else { return }
        haptics.impact(.light)
        state.segmentMode = segment
        scheduleRender()
    }

    func sliderChanged(to value: Double) {
        let snapped = snapToTicks(value)
        if abs(snapped - lastSliderValue) > 0.18 {
            haptics.selection()
            lastSliderValue = snapped
        }
        state.intensity = snapped
        scheduleRender()
    }

    func updateAdjustments(_ adjustments: Adjustments) {
        state.adjustments = adjustments
        scheduleRender()
    }

    func saveToPhotos() {
        guard let image = renderedImage ?? sourceImage else { return }
        Task { [weak self] in
            guard let self else { return }
            do {
                try await exporter.saveToPhotos(image)
                await MainActor.run {
                    self.haptics.notification(.success)
                }
            } catch {
                await MainActor.run {
                    self.lastError = error.localizedDescription
                    self.haptics.notification(.error)
                }
            }
        }
    }

    func shareImage() -> UIImage? {
        renderedImage ?? sourceImage
    }

    func resetAdjustments() {
        state.adjustments = .neutral
        haptics.impact(.light)
        scheduleRender()
    }

    // MARK: - Pipeline

    private func scheduleRender() {
        renderTask?.cancel()
        renderTask = Task { [weak self] in
            try? await Task.sleep(nanoseconds: 80_000_000) // debounce ~80ms
            guard !Task.isCancelled else { return }
            await self?.render()
        }
    }

    private func prepareSegmentation() async {
        guard let source = sourceCIImage else { return }
        phase = .analyzing
        do {
            let mask = try await segmentation.segmentPerson(in: source)
            self.maskCIImage = mask
            self.state.hasSegmentation = true
        } catch {
            self.maskCIImage = nil
            self.state.hasSegmentation = false
        }
    }

    private func render() async {
        guard let source = sourceCIImage else { return }
        phase = .applyingStyle
        defer { phase = .ready }
        do {
            let output = try await styleTransfer.apply(
                style: state.style,
                to: source,
                mask: maskCIImage,
                segment: state.segmentMode,
                intensity: state.intensity,
                adjustments: state.adjustments
            )
            if let rendered = exporter.render(output) {
                self.renderedImage = rendered
            }
        } catch {
            self.lastError = error.localizedDescription
            self.phase = .failed(error.localizedDescription)
        }
    }

    private func snapToTicks(_ value: Double) -> Double {
        let ticks: [Double] = [0.0, 0.25, 0.5, 0.75, 1.0]
        for tick in ticks where abs(tick - value) < 0.03 {
            return tick
        }
        return value
    }
}
