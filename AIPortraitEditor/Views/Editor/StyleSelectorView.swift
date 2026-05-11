import SwiftUI

/// Horizontal carousel of style chips.  Each chip shows a small thumbnail (or
/// gradient placeholder) and the localised style name.
struct StyleSelectorView: View {
    let styles: [Style]
    let selectedID: String
    let onSelect: (Style) -> Void

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: AppSpacing.sm) {
                ForEach(styles) { style in
                    StyleChip(style: style, isSelected: style.id == selectedID)
                        .onTapGesture { onSelect(style) }
                }
            }
            .padding(.horizontal, AppSpacing.md)
        }
    }
}

private struct StyleChip: View {
    let style: Style
    let isSelected: Bool

    var body: some View {
        VStack(spacing: AppSpacing.xxs) {
            ZStack {
                if let img = UIImage(named: style.thumbnailAssetName) {
                    Image(uiImage: img)
                        .resizable()
                        .scaledToFill()
                } else {
                    LinearGradient(
                        colors: [style.accent, style.accent.opacity(0.5)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                }
                if style.isPremium {
                    VStack {
                        HStack {
                            Spacer()
                            Image(systemName: "crown.fill")
                                .font(.system(size: 10, weight: .bold))
                                .foregroundStyle(.white)
                                .padding(4)
                                .background(Circle().fill(.black.opacity(0.4)))
                                .padding(4)
                        }
                        Spacer()
                    }
                }
            }
            .frame(width: 72, height: 72)
            .clipShape(RoundedRectangle(cornerRadius: AppSpacing.cornerRadius, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: AppSpacing.cornerRadius, style: .continuous)
                    .stroke(isSelected ? AppColors.accent : .clear, lineWidth: 3)
            )

            Text(style.nameKey)
                .font(AppTypography.caption)
                .foregroundStyle(isSelected ? AppColors.accent : AppColors.textSecondary)
                .lineLimit(1)
        }
        .frame(width: 84)
        .accessibilityElement(children: .combine)
        .accessibilityAddTraits(isSelected ? .isSelected : [])
    }
}
