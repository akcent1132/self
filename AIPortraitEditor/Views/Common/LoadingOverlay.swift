import SwiftUI

/// Overlay shown while the AI pipeline is running.  Uses a Lottie animation
/// when available and falls back to a system spinner otherwise.
struct LoadingOverlay: View {
    let titleKey: LocalizedStringKey
    let animationName: String

    var body: some View {
        ZStack {
            AppColors.background.opacity(0.55)
                .ignoresSafeArea()

            VStack(spacing: AppSpacing.md) {
                LottieView(name: animationName)
                    .frame(width: 120, height: 120)
                Text(titleKey)
                    .font(AppTypography.headline)
                    .foregroundStyle(AppColors.textPrimary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, AppSpacing.lg)
            }
            .padding(AppSpacing.lg)
            .background(
                RoundedRectangle(cornerRadius: AppSpacing.cornerRadiusLarge, style: .continuous)
                    .fill(AppColors.surfaceElevated)
            )
            .shadow(color: .black.opacity(0.2), radius: 20, x: 0, y: 8)
        }
        .transition(.opacity.combined(with: .scale))
    }
}
