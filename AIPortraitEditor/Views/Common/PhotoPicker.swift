import SwiftUI
import PhotosUI
import UIKit

/// SwiftUI wrapper around `PHPickerViewController` so we can present a
/// system-styled picker with multi-image support.
struct PhotoPicker: UIViewControllerRepresentable {
    @Binding var isPresented: Bool
    var selectionLimit: Int = 1
    var onPicked: (UIImage) -> Void

    func makeUIViewController(context: Context) -> PHPickerViewController {
        var config = PHPickerConfiguration(photoLibrary: .shared())
        config.filter = .images
        config.selectionLimit = selectionLimit
        config.preferredAssetRepresentationMode = .current
        let picker = PHPickerViewController(configuration: config)
        picker.delegate = context.coordinator
        return picker
    }

    func updateUIViewController(_ uiViewController: PHPickerViewController, context: Context) {}

    func makeCoordinator() -> Coordinator {
        Coordinator(onPicked: onPicked, isPresented: $isPresented)
    }

    final class Coordinator: NSObject, PHPickerViewControllerDelegate {
        let onPicked: (UIImage) -> Void
        @Binding var isPresented: Bool

        init(onPicked: @escaping (UIImage) -> Void, isPresented: Binding<Bool>) {
            self.onPicked = onPicked
            self._isPresented = isPresented
        }

        func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
            isPresented = false
            guard let provider = results.first?.itemProvider,
                  provider.canLoadObject(ofClass: UIImage.self) else { return }
            provider.loadObject(ofClass: UIImage.self) { [weak self] image, _ in
                guard let image = image as? UIImage else { return }
                DispatchQueue.main.async { self?.onPicked(image) }
            }
        }
    }
}
