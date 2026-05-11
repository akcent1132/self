import CoreImage
import UIKit

extension CIImage {
    /// Renders the receiver to a `UIImage` using a shared context.
    func toUIImage(context: CIContext = CIContext()) -> UIImage? {
        guard let cgImage = context.createCGImage(self, from: extent) else { return nil }
        return UIImage(cgImage: cgImage)
    }
}
