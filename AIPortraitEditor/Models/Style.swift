import Foundation
import SwiftUI

/// A visual style that can be applied to an image via Core ML style transfer.
///
/// Styles ship with the app as bundled `.mlmodel` files compiled into `.mlmodelc`
/// at build time.  The `modelName` corresponds to the compiled model resource
/// name (without extension).  When the model file is missing on disk, the style
/// is treated as a *preview-only* placeholder so the UI can still showcase the
/// full catalogue while heavier models are downloaded on demand.
struct Style: Identifiable, Hashable, Equatable {
    let id: String
    let nameKey: LocalizedStringKey
    let displayName: String
    let modelName: String?
    let thumbnailAssetName: String
    let accent: Color
    let isPremium: Bool

    static let none = Style(
        id: "none",
        nameKey: "style.none",
        displayName: "Original",
        modelName: nil,
        thumbnailAssetName: "style.thumb.none",
        accent: Color(red: 0.55, green: 0.55, blue: 0.55),
        isPremium: false
    )
}

extension Style {
    /// Built-in catalogue used by `StyleManager`.  Real models can be added
    /// later by dropping additional `.mlmodel` files into the bundle and
    /// extending this list.
    static let builtIn: [Style] = [
        .none,
        Style(
            id: "vangogh",
            nameKey: "style.vangogh",
            displayName: "Van Gogh",
            modelName: "VanGoghStyle",
            thumbnailAssetName: "style.thumb.vangogh",
            accent: Color(red: 0.99, green: 0.78, blue: 0.27),
            isPremium: false
        ),
        Style(
            id: "mosaic",
            nameKey: "style.mosaic",
            displayName: "Mosaic",
            modelName: "MosaicStyle",
            thumbnailAssetName: "style.thumb.mosaic",
            accent: Color(red: 0.36, green: 0.66, blue: 0.95),
            isPremium: false
        ),
        Style(
            id: "candy",
            nameKey: "style.candy",
            displayName: "Candy",
            modelName: "CandyStyle",
            thumbnailAssetName: "style.thumb.candy",
            accent: Color(red: 0.96, green: 0.42, blue: 0.62),
            isPremium: false
        ),
        Style(
            id: "noir",
            nameKey: "style.noir",
            displayName: "Noir",
            modelName: "NoirStyle",
            thumbnailAssetName: "style.thumb.noir",
            accent: Color(red: 0.18, green: 0.18, blue: 0.20),
            isPremium: true
        ),
        Style(
            id: "pop",
            nameKey: "style.pop",
            displayName: "Pop",
            modelName: "PopStyle",
            thumbnailAssetName: "style.thumb.pop",
            accent: Color(red: 0.95, green: 0.36, blue: 0.36),
            isPremium: true
        ),
        Style(
            id: "ink",
            nameKey: "style.ink",
            displayName: "Ink",
            modelName: "InkStyle",
            thumbnailAssetName: "style.thumb.ink",
            accent: Color(red: 0.33, green: 0.78, blue: 0.62),
            isPremium: false
        )
    ]
}
