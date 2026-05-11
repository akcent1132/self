import SwiftUI
import UIKit

#if canImport(Lottie)
import Lottie

/// Renders a Lottie JSON animation embedded in the app bundle.
/// Gracefully falls back to a tasteful pulse animation when the named asset
/// is not (yet) shipped with the app.
struct LottieView: View {
    let name: String
    var loopMode: LottieLoopMode = .loop
    var speed: CGFloat = 1.0

    var body: some View {
        if LottieAnimation.named(name) != nil {
            _LottieRepresentable(name: name, loopMode: loopMode, speed: speed)
        } else {
            FallbackPulseView()
        }
    }
}

private struct _LottieRepresentable: UIViewRepresentable {
    let name: String
    var loopMode: LottieLoopMode
    var speed: CGFloat

    func makeUIView(context: Context) -> UIView {
        let container = UIView(frame: .zero)
        container.backgroundColor = .clear

        let animationView = LottieAnimationView(name: name)
        animationView.contentMode = .scaleAspectFit
        animationView.loopMode = loopMode
        animationView.animationSpeed = speed
        animationView.backgroundBehavior = .pauseAndRestore
        animationView.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(animationView)

        NSLayoutConstraint.activate([
            animationView.topAnchor.constraint(equalTo: container.topAnchor),
            animationView.bottomAnchor.constraint(equalTo: container.bottomAnchor),
            animationView.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            animationView.trailingAnchor.constraint(equalTo: container.trailingAnchor)
        ])

        animationView.play()
        return container
    }

    func updateUIView(_ uiView: UIView, context: Context) {}
}
#else
/// Fallback used when the Lottie package isn't available (e.g. during the
/// initial SwiftPM resolution).  Shows a tasteful animated placeholder so the
/// app keeps building.
struct LottieView: View {
    let name: String

    var body: some View {
        FallbackPulseView()
    }
}
#endif

/// Pure-SwiftUI looping pulse used as a fallback for Lottie animations.
private struct FallbackPulseView: View {
    @State private var pulse: Bool = false

    var body: some View {
        ZStack {
            Circle()
                .stroke(AppColors.accent.opacity(0.3), lineWidth: 4)
                .scaleEffect(pulse ? 1.1 : 0.9)
            Circle()
                .stroke(AppColors.accent, lineWidth: 2)
                .scaleEffect(pulse ? 0.6 : 1.0)
        }
        .onAppear {
            withAnimation(.easeInOut(duration: 1.0).repeatForever(autoreverses: true)) {
                pulse.toggle()
            }
        }
    }
}
