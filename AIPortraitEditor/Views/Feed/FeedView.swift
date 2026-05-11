import SwiftUI

struct FeedView: View {
    @StateObject private var viewModel = FeedViewModel()

    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVStack(spacing: AppSpacing.md) {
                    filterPicker
                    ForEach(viewModel.posts) { post in
                        FeedCard(post: post)
                            .padding(.horizontal, AppSpacing.md)
                    }
                }
                .padding(.vertical, AppSpacing.md)
            }
            .background(AppColors.background.ignoresSafeArea())
            .navigationTitle(Text("feed.title"))
            .navigationBarTitleDisplayMode(.large)
            .refreshable { await viewModel.refresh() }
            .task { await viewModel.refresh() }
        }
        .tint(AppColors.accent)
    }

    private var filterPicker: some View {
        Picker(selection: $viewModel.filter) {
            ForEach(FeedViewModel.Filter.allCases) { filter in
                Text(filter.titleKey).tag(filter)
            }
        } label: {
            EmptyView()
        }
        .pickerStyle(.segmented)
        .padding(.horizontal, AppSpacing.md)
        .onChange(of: viewModel.filter) { _, _ in
            Task { await viewModel.refresh() }
        }
    }
}

private struct FeedCard: View {
    let post: FeedPost

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            header
            image
            footer
        }
        .background(
            RoundedRectangle(cornerRadius: AppSpacing.cornerRadiusLarge, style: .continuous)
                .fill(AppColors.surface)
        )
        .overlay(
            RoundedRectangle(cornerRadius: AppSpacing.cornerRadiusLarge, style: .continuous)
                .stroke(AppColors.border, lineWidth: 0.5)
        )
        .accessibilityElement(children: .contain)
    }

    private var header: some View {
        HStack(spacing: AppSpacing.sm) {
            Circle()
                .fill(LinearGradient(
                    colors: [AppColors.accent, AppColors.accentSecondary],
                    startPoint: .topLeading, endPoint: .bottomTrailing
                ))
                .frame(width: 36, height: 36)
                .overlay(
                    Text(String(post.authorName.prefix(1)))
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(.white)
                )
            VStack(alignment: .leading, spacing: 0) {
                Text(post.authorName)
                    .font(AppTypography.headline)
                    .foregroundStyle(AppColors.textPrimary)
                Text(post.styleName)
                    .font(AppTypography.caption)
                    .foregroundStyle(AppColors.textSecondary)
            }
            Spacer()
            Text(post.createdAt, style: .relative)
                .font(AppTypography.caption)
                .foregroundStyle(AppColors.textSecondary)
        }
        .padding(AppSpacing.md)
    }

    private var image: some View {
        ZStack {
            if let img = UIImage(named: post.imageAsset) {
                Image(uiImage: img)
                    .resizable()
                    .scaledToFill()
            } else {
                LinearGradient(
                    colors: [AppColors.accent.opacity(0.5), AppColors.accentSecondary.opacity(0.5)],
                    startPoint: .topLeading, endPoint: .bottomTrailing
                )
            }
        }
        .frame(height: 280)
        .frame(maxWidth: .infinity)
        .clipped()
    }

    private var footer: some View {
        HStack(spacing: AppSpacing.md) {
            Label("\(post.likeCount)", systemImage: "heart")
                .labelStyle(.titleAndIcon)
                .foregroundStyle(AppColors.textSecondary)
                .accessibilityLabel(Text("feed.likes"))
            Label("\(post.commentCount)", systemImage: "bubble.right")
                .labelStyle(.titleAndIcon)
                .foregroundStyle(AppColors.textSecondary)
                .accessibilityLabel(Text("feed.comments"))
            Spacer()
            Image(systemName: "bookmark")
                .foregroundStyle(AppColors.textSecondary)
        }
        .font(AppTypography.caption)
        .padding(AppSpacing.md)
    }
}

#Preview {
    FeedView()
}
