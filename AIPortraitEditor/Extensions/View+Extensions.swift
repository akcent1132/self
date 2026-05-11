import SwiftUI

extension View {
    /// Applies a glassy card background using the elevated surface token.
    func card(
        cornerRadius: CGFloat = AppSpacing.cornerRadius,
        padding: CGFloat = AppSpacing.md
    ) -> some View {
        self
            .padding(padding)
            .background(
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .fill(AppColors.surface)
            )
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .stroke(AppColors.border, lineWidth: 0.5)
            )
    }

    @ViewBuilder
    func conditional<Content: View>(_ condition: Bool, transform: (Self) -> Content) -> some View {
        if condition { transform(self) } else { self }
    }
}
