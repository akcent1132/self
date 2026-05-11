import Foundation

/// Sample model for the community Feed screen.  In production these would be
/// fetched from a backend (CloudKit, Firebase, custom API).  Here we just keep
/// a curated list bundled with the app.
struct FeedPost: Identifiable, Hashable {
    let id: UUID
    let authorName: String
    let authorAvatarAsset: String
    let imageAsset: String
    let styleName: String
    let likeCount: Int
    let commentCount: Int
    let createdAt: Date

    static let samples: [FeedPost] = [
        FeedPost(
            id: UUID(),
            authorName: "Anna Lebedeva",
            authorAvatarAsset: "avatar.placeholder",
            imageAsset: "feed.sample.1",
            styleName: "Van Gogh",
            likeCount: 248,
            commentCount: 12,
            createdAt: Date().addingTimeInterval(-3600)
        ),
        FeedPost(
            id: UUID(),
            authorName: "Marko Petrović",
            authorAvatarAsset: "avatar.placeholder",
            imageAsset: "feed.sample.2",
            styleName: "Mosaic",
            likeCount: 1024,
            commentCount: 88,
            createdAt: Date().addingTimeInterval(-7200)
        ),
        FeedPost(
            id: UUID(),
            authorName: "Сергей Иванов",
            authorAvatarAsset: "avatar.placeholder",
            imageAsset: "feed.sample.3",
            styleName: "Noir",
            likeCount: 64,
            commentCount: 3,
            createdAt: Date().addingTimeInterval(-86_400)
        ),
        FeedPost(
            id: UUID(),
            authorName: "Mei Tanaka",
            authorAvatarAsset: "avatar.placeholder",
            imageAsset: "feed.sample.4",
            styleName: "Candy",
            likeCount: 412,
            commentCount: 27,
            createdAt: Date().addingTimeInterval(-172_800)
        )
    ]
}
