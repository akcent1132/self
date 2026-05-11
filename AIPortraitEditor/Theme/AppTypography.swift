import SwiftUI

/// Typography tokens.  All fonts use *Dynamic Type* via `.relativeTo` so they
/// scale with the user's preferred content size.
enum AppTypography {
    static let largeTitle: Font = .system(.largeTitle, design: .rounded).weight(.bold)
    static let title: Font = .system(.title2, design: .rounded).weight(.semibold)
    static let headline: Font = .system(.headline, design: .rounded)
    static let body: Font = .system(.body, design: .default)
    static let caption: Font = .system(.caption, design: .rounded)
    static let monoNumeric: Font = .system(.footnote, design: .monospaced).weight(.medium)
}
