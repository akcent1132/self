import Foundation
import SwiftUI

/// Describes which region of the image a style should be applied to.
enum SegmentMode: String, CaseIterable, Identifiable, Hashable {
    case portrait
    case background
    case global

    var id: String { rawValue }

    var titleKey: LocalizedStringKey {
        switch self {
        case .portrait: return "segment.portrait"
        case .background: return "segment.background"
        case .global: return "segment.global"
        }
    }

    var systemImage: String {
        switch self {
        case .portrait: return "person.crop.circle"
        case .background: return "photo.fill.on.rectangle.fill"
        case .global: return "globe"
        }
    }
}
