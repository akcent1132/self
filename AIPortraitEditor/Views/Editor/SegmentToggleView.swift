import SwiftUI

/// Compact segmented control that lets the user pick where the current style
/// is applied: portrait, background, or both.
struct SegmentToggleView: View {
    @Binding var selection: SegmentMode
    let hasSegmentation: Bool

    var body: some View {
        HStack(spacing: 0) {
            ForEach(SegmentMode.allCases) { mode in
                let disabled = !hasSegmentation && mode != .global
                Button {
                    guard !disabled else { return }
                    withAnimation(.easeInOut(duration: 0.18)) {
                        selection = mode
                    }
                } label: {
                    HStack(spacing: AppSpacing.xxs) {
                        Image(systemName: mode.systemImage)
                            .font(.system(size: 14, weight: .semibold))
                        Text(mode.titleKey)
                            .font(AppTypography.caption)
                    }
                    .padding(.vertical, AppSpacing.sm)
                    .frame(maxWidth: .infinity)
                    .foregroundStyle(
                        selection == mode
                            ? AppColors.textPrimary
                            : AppColors.textSecondary
                    )
                    .background {
                        if selection == mode {
                            RoundedRectangle(cornerRadius: AppSpacing.cornerRadius - 2, style: .continuous)
                                .fill(AppColors.surfaceElevated)
                                .shadow(color: .black.opacity(0.08), radius: 4, x: 0, y: 2)
                        }
                    }
                }
                .buttonStyle(.plain)
                .opacity(disabled ? 0.4 : 1.0)
                .accessibilityLabel(Text(mode.titleKey))
                .accessibilityAddTraits(selection == mode ? .isSelected : [])
            }
        }
        .padding(AppSpacing.xxs)
        .background(
            RoundedRectangle(cornerRadius: AppSpacing.cornerRadius, style: .continuous)
                .fill(AppColors.surface)
        )
    }
}
