import Foundation
import SwiftUI

@MainActor
final class FeedViewModel: ObservableObject {

    enum Filter: String, CaseIterable, Identifiable {
        case trending, fresh, following
        var id: String { rawValue }
        var titleKey: LocalizedStringKey {
            switch self {
            case .trending: return "feed.filter.trending"
            case .fresh: return "feed.filter.fresh"
            case .following: return "feed.filter.following"
            }
        }
    }

    @Published private(set) var posts: [FeedPost] = FeedPost.samples
    @Published var filter: Filter = .trending
    @Published var isRefreshing: Bool = false

    func refresh() async {
        isRefreshing = true
        defer { isRefreshing = false }
        try? await Task.sleep(nanoseconds: 700_000_000)
        switch filter {
        case .trending:
            posts = FeedPost.samples.sorted { $0.likeCount > $1.likeCount }
        case .fresh:
            posts = FeedPost.samples.sorted { $0.createdAt > $1.createdAt }
        case .following:
            posts = Array(FeedPost.samples.shuffled().prefix(2))
        }
    }
}
