import Foundation
import UIKit
import Photos

/// Wraps an item shown in the Home/Gallery grid.  Backed by a `PHAsset`
/// identifier in real usage; falls back to bundled placeholders so the grid is
/// never empty during onboarding.
struct GalleryAsset: Identifiable, Hashable {
    let id: String
    let assetIdentifier: String?
    let placeholderName: String?
    let createdAt: Date?

    init(id: String = UUID().uuidString,
         assetIdentifier: String? = nil,
         placeholderName: String? = nil,
         createdAt: Date? = nil) {
        self.id = id
        self.assetIdentifier = assetIdentifier
        self.placeholderName = placeholderName
        self.createdAt = createdAt
    }
}

extension GalleryAsset {
    static let placeholders: [GalleryAsset] = (1...6).map { idx in
        GalleryAsset(
            id: "placeholder.\(idx)",
            assetIdentifier: nil,
            placeholderName: "gallery.placeholder.\(idx)",
            createdAt: Date().addingTimeInterval(-Double(idx) * 86_400)
        )
    }
}
