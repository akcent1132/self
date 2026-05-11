import SwiftUI

/// Real-time intensity slider.  Snap-to-tick behaviour and selection haptics
/// live in `EditorViewModel.sliderChanged(to:)` so the visual stays a plain
/// system `Slider` — fully accessible and Dynamic-Type friendly.
struct IntensitySliderView: View {
    @Binding var value: Double

    private let ticks: [Double] = [0.0, 0.25, 0.5, 0.75, 1.0]

    var body: some View {
        VStack(alignment: .leading, spacing: AppSpacing.xs) {
            HStack {
                Text("editor.intensity")
                    .font(AppTypography.caption)
                    .foregroundStyle(AppColors.textSecondary)
                Spacer()
                Text(percentageText)
                    .font(AppTypography.monoNumeric)
                    .foregroundStyle(AppColors.textPrimary)
                    .monospacedDigit()
            }

            ZStack {
                tickMarks
                Slider(value: $value, in: 0...1)
                    .tint(AppColors.accent)
                    .accessibilityValue(Text(percentageText))
            }
        }
        .padding(AppSpacing.sm)
        .background(
            RoundedRectangle(cornerRadius: AppSpacing.cornerRadius, style: .continuous)
                .fill(AppColors.surface)
        )
    }

    private var tickMarks: some View {
        GeometryReader { proxy in
            ForEach(ticks, id: \.self) { tick in
                Circle()
                    .fill(AppColors.border)
                    .frame(width: 3, height: 3)
                    .position(
                        x: proxy.size.width * tick,
                        y: proxy.size.height / 2
                    )
            }
        }
        .allowsHitTesting(false)
        .frame(height: 24)
    }

    private var percentageText: String {
        let percent = Int((value * 100).rounded())
        return "\(percent)%"
    }
}
