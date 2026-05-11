import Foundation
import Factory

/// Service registrations for the entire app.
///
/// Every concrete service is registered against its protocol so view-models
/// can depend on the abstraction.  Lifetimes follow the `Factory` defaults:
///   * `.singleton` for heavy services that hold caches (StyleManager,
///     ImageSegmentationService, StyleTransferService).
///   * `.shared`/transient for lightweight helpers (Haptics, Export).
extension Container {
    var styleManager: Factory<StyleManaging> {
        self { StyleManager() }.singleton
    }

    var segmentationService: Factory<ImageSegmentationServicing> {
        self { ImageSegmentationService() }.singleton
    }

    var styleTransferService: Factory<StyleTransferServicing> {
        self {
            StyleTransferService(styleManager: self.styleManager())
        }.singleton
    }

    var hapticsService: Factory<HapticsServicing> {
        self { HapticsService() }.shared
    }

    var imageExportService: Factory<ImageExportServicing> {
        self { ImageExportService() }.shared
    }

    var photoLibraryService: Factory<PhotoLibraryServicing> {
        self { PhotoLibraryService() }.singleton
    }
}
