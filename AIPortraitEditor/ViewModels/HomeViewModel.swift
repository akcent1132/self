import Foundation
import SwiftUI
import Photos
import Factory

@MainActor
final class HomeViewModel: ObservableObject {

    @Injected(\.photoLibraryService) private var photoLibrary
    @Injected(\.hapticsService) private var haptics

    @Published private(set) var assets: [GalleryAsset] = GalleryAsset.placeholders
    @Published private(set) var authorizationStatus: PHAuthorizationStatus = .notDetermined
    @Published var isLoading: Bool = false
    @Published var selectedAsset: GalleryAsset?

    func onAppear() async {
        authorizationStatus = PHPhotoLibrary.authorizationStatus(for: .readWrite)
        if authorizationStatus == .notDetermined {
            authorizationStatus = await photoLibrary.requestAuthorization()
        }
        await refresh()
    }

    func refresh() async {
        isLoading = true
        defer { isLoading = false }
        let items = await photoLibrary.recentPhotos(limit: 120)
        self.assets = items
    }

    func select(_ asset: GalleryAsset) {
        haptics.selection()
        selectedAsset = asset
    }
}
