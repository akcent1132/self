import SwiftUI

/// Bottom sheet exposing tonal & colour adjustments (brightness, contrast,
/// saturation, warmth, vignette).
struct AdjustmentsSheet: View {
    @Binding var adjustments: Adjustments
    let onReset: () -> Void

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: AppSpacing.lg) {
                    AdjustmentRow(
                        titleKey: "adjust.brightness",
                        value: $adjustments.brightness,
                        range: -0.5...0.5,
                        formatter: percentSigned
                    )
                    AdjustmentRow(
                        titleKey: "adjust.contrast",
                        value: $adjustments.contrast,
                        range: 0.5...1.5,
                        formatter: { String(format: "%.2fx", $0) }
                    )
                    AdjustmentRow(
                        titleKey: "adjust.saturation",
                        value: $adjustments.saturation,
                        range: 0.0...2.0,
                        formatter: { String(format: "%.2fx", $0) }
                    )
                    AdjustmentRow(
                        titleKey: "adjust.warmth",
                        value: $adjustments.warmth,
                        range: -1.0...1.0,
                        formatter: percentSigned
                    )
                    AdjustmentRow(
                        titleKey: "adjust.vignette",
                        value: $adjustments.vignette,
                        range: 0.0...1.0,
                        formatter: percent
                    )
                }
                .padding(.horizontal, AppSpacing.md)
                .padding(.top, AppSpacing.md)
                .padding(.bottom, AppSpacing.xl)
            }
            .background(AppColors.background.ignoresSafeArea())
            .navigationTitle(Text("adjust.title"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button(role: .destructive) {
                        onReset()
                    } label: {
                        Text("adjust.reset")
                    }
                }
            }
        }
    }

    private func percent(_ value: Double) -> String {
        "\(Int((value * 100).rounded()))%"
    }

    private func percentSigned(_ value: Double) -> String {
        let percent = Int((value * 100).rounded())
        return percent >= 0 ? "+\(percent)%" : "\(percent)%"
    }
}

private struct AdjustmentRow: View {
    let titleKey: LocalizedStringKey
    @Binding var value: Double
    let range: ClosedRange<Double>
    let formatter: (Double) -> String

    var body: some View {
        VStack(alignment: .leading, spacing: AppSpacing.xs) {
            HStack {
                Text(titleKey)
                    .font(AppTypography.headline)
                    .foregroundStyle(AppColors.textPrimary)
                Spacer()
                Text(formatter(value))
                    .font(AppTypography.monoNumeric)
                    .foregroundStyle(AppColors.textSecondary)
                    .monospacedDigit()
            }
            Slider(value: $value, in: range)
                .tint(AppColors.accent)
                .accessibilityValue(Text(formatter(value)))
        }
        .padding(AppSpacing.md)
        .background(
            RoundedRectangle(cornerRadius: AppSpacing.cornerRadius, style: .continuous)
                .fill(AppColors.surface)
        )
    }
}
