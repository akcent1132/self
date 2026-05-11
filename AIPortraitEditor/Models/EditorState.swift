import Foundation
import UIKit

/// Lightweight value type that represents the *user-facing* state of the
/// editor (selected style, intensity, adjustments, …).  The view model owns it
/// and re-renders the canvas whenever any field changes.
struct EditorState: Equatable {
    var style: Style = .none
    var segmentMode: SegmentMode = .portrait
    var intensity: Double = 0.8
    var adjustments: Adjustments = .neutral
    var hasSegmentation: Bool = false
}

/// Tonal & color adjustments applied as a post-processing pass over the
/// stylised image using Core Image filters.
struct Adjustments: Equatable {
    var brightness: Double
    var contrast: Double
    var saturation: Double
    var warmth: Double
    var vignette: Double

    static let neutral = Adjustments(
        brightness: 0.0,
        contrast: 1.0,
        saturation: 1.0,
        warmth: 0.0,
        vignette: 0.0
    )

    var isNeutral: Bool { self == .neutral }
}

/// Possible progress states surfaced in the UI.
enum EditorPhase: Equatable {
    case idle
    case loadingImage
    case analyzing
    case applyingStyle
    case ready
    case failed(String)
}
