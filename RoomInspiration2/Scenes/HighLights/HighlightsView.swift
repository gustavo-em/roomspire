import SwiftUI
import SwiftData

struct HighlightsView: View {

    @State private var viewModel = HighlightsViewModel()
    @Query private var favorites: [FavoritePhoto]
    @Environment(\.modelContext) private var modelContext

    private var favoriteIDs: Set<Int> {
        Set(favorites.map(\.photoID))
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                filterBar
                content
            }
            .navigationTitle("Inspiration")
            .searchable(text: $viewModel.criteria.text, prompt: "Search ideas (e.g. wooden table)")
        }
        .task(id: viewModel.criteria) {
            do {
                try await Task.sleep(for: .milliseconds(400))
            } catch {
                return
            }
            await viewModel.load()
        }
    }

    @ViewBuilder
    private var content: some View {
        if let error = viewModel.errorMessage {
            errorState(error)
        } else if viewModel.blocks.isEmpty && viewModel.isLoading {
            ProgressView("Loading inspiration…")
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        } else if viewModel.blocks.isEmpty {
            if viewModel.criteria.text.isEmpty {
                ContentUnavailableView.search
            } else {
                ContentUnavailableView.search(text: viewModel.criteria.text)
            }
        } else {
            photoGrid
        }
    }

    private var photoGrid: some View {
        ScrollView {
            LazyVStack(spacing: 8) {
                ForEach(viewModel.blocks) { block in
                    EqualizedMasonryLayout(aspectRatios: block.photos.map(\.aspectRatio)) {
                        ForEach(block.photos) { photo in
                            PhotoCard(photo: photo, isFavorite: favoriteIDs.contains(photo.id)) {
                                toggleFavorite(photo)
                            }
                        }
                    }
                }
            }
            .padding(.horizontal, 8)
            .padding(.top, 8)
        }
        .opacity(viewModel.isLoading ? 0.5 : 1)
        .animation(.easeInOut(duration: 0.2), value: viewModel.isLoading)
        .refreshable {
            await viewModel.load()
        }
        .sensoryFeedback(.impact(weight: .light), trigger: favorites.count)
    }

    private func toggleFavorite(_ photo: PexelsPhoto) {
        withAnimation(.snappy) {
            FavoritePhoto.toggle(photo, room: viewModel.criteria.room, style: viewModel.criteria.style, in: modelContext)
        }
    }

    private var filterBar: some View {
        VStack(alignment: .leading, spacing: 8) {
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(RoomType.allCases) { room in
                        FilterChip(
                            title: room.title,
                            systemImage: room.symbolName,
                            isSelected: viewModel.criteria.room == room
                        ) {
                            viewModel.toggle(room)
                        }
                    }
                }
                .padding(.horizontal)
            }

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(DecorStyle.allCases) { style in
                        FilterChip(title: style.title, isSelected: viewModel.criteria.style == style) {
                            viewModel.toggle(style)
                        }
                    }

                    Divider()
                        .frame(height: 24)

                    ForEach(PhotoColor.allCases) { color in
                        ColorChip(color: color, isSelected: viewModel.criteria.color == color) {
                            viewModel.toggle(color)
                        }
                    }

                    if !viewModel.criteria.isEmpty {
                        Button("Clear", systemImage: "xmark.circle") {
                            viewModel.clearFilters()
                        }
                        .font(.subheadline)
                    }
                }
                .padding(.horizontal)
            }
        }
        .padding(.vertical, 8)
        .animation(.snappy, value: viewModel.criteria)
    }

    private func errorState(_ message: String) -> some View {
        ContentUnavailableView {
            Label("Could not load photos", systemImage: "wifi.exclamationmark")
        } description: {
            Text(message)
        } actions: {
            Button("Try again") {
                Task { await viewModel.load() }
            }
            .buttonStyle(.borderedProminent)
        }
    }
}

#Preview {
    HighlightsView()
        .modelContainer(for: [UserPhoto.self, FavoritePhoto.self], inMemory: true)
}
