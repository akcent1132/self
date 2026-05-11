import SwiftUI

/// Semantic colour tokens used throughout the UI.
///
/// All colours are defined inside `Assets.xcassets` so they automatically
/// adapt to Dark / Light appearance and respect *Increased Contrast* in
/// Accessibility settings.
enum AppColors {
    static let background = Color("BackgroundPrimary")
    static let backgroundSecondary = Color("BackgroundSecondary")
    static let surface = Color("Surface")
    static let surfaceElevated = Color("SurfaceElevated")
    static let textPrimary = Color("TextPrimary")
    static let textSecondary = Color("TextSecondary")
    static let accent = Color("Accent")
    static let accentSecondary = Color("AccentSecondary")
    static let border = Color("Border")
    static let danger = Color("Danger")
    static let success = Color("Success")
}
