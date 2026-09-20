import SwiftUI
import SwiftData

struct ProfileView: View {

    enum Section: String, CaseIterable, Identifiable {
        case mine = "My rooms"
        case favorites = "Favorites"
        var id: Self { self }
    }

    @Query(sort: \UserPhoto.createdAt, order: .reverse) private var photos: [UserPhoto]
    @Query(sort: \FavoritePhoto.savedAt, order: .reverse) private var favorites: [FavoritePhoto]
    @Environment(\.modelContext) private var modelContext

    @State private var section: Section = .mine
    @State private var showAddPhoto = false
    @State private var selectedPhoto: UserPhoto?
    @State private var selectedFavorite: FavoritePhoto?
    @State private var roomFilter: RoomType?

    private var visiblePhotos: [UserPhoto] {
        guard let roomFilter else { return photos }
        return photos.filter { $0.room == roomFilter }
    }

    private var visibleFavorites: [FavoritePhoto] {
        guard let roomFilter else { return favorites }
        return favorites.filter { $0.room == roomFilter }
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                sectionPicker
                roomChips
                switch section {
                case .mine: myPhotosContent
                case .favorites: favoritesContent
                }
            }
            .navigationTitle("Profile")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button("Add photo", systemImage: "plus") {
                        showAddPhoto = true
                    }
                }
            }
            .sheet(isPresented: $showAddPhoto) {
                AddPhotoView()
            }
            .sheet(item: $selectedPhoto) { photo in
                UserPhotoDetailView(photo: photo)
            }
            .sheet(item: $selectedFavorite) { favorite in
                FavoriteDetailView(favorite: favorite)
            }
        }
    }

    private var sectionPicker: some View {
        Picker("Section", selection: $section) {
            ForEach(Section.allCases) { section in
                Text(section.rawValue).tag(section)
            }
        }
        .pickerStyle(.segmented)
        .padding(.horizontal)
        .padding(.top, 4)
    }

    private var roomChips: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                FilterChip(title: "All", isSelected: roomFilter == nil) {
                    roomFilter = nil
                }
                ForEach(RoomType.allCases) { room in
                    FilterChip(title: room.title, systemImage: room.symbolName, isSelected: roomFilter == room) {
                        roomFilter = roomFilter == room ? nil : room
                    }
                }
            }
            .padding(.horizontal)
            .padding(.vertical, 8)
        }
        .animation(.snappy, value: roomFilter)
    }

    @ViewBuilder
    private var myPhotosContent: some View {
        if photos.isEmpty {
            ContentUnavailableView {
                Label("No rooms yet", systemImage: "photo.on.rectangle.angled")
            } description: {
                Text("Take photos of your rooms and keep them here with room, style and notes.")
            } actions: {
                Button("Add photo") { showAddPhoto = true }
                    .buttonStyle(.borderedProminent)
            }
        } else if visiblePhotos.isEmpty {
            ContentUnavailableView("Nothing in this room", systemImage: "sofa")
        } else {
            ScrollView {
                LazyVStack(spacing: 8) {
                    ForEach(Array(visiblePhotos.chunked(into: 6).enumerated()), id: \.offset) { _, block in
                        EqualizedMasonryLayout(aspectRatios: block.map(\.aspectRatio)) {
                            ForEach(block) { photo in
                                Button {
                                    selectedPhoto = photo
                                } label: {
                                    LocalPhotoCard(photo: photo)
                                }
                                .buttonStyle(.plain)
                            }
                        }
                    }
                }
                .padding(.horizontal, 8)
            }
        }
    }

    @ViewBuilder
    private var favoritesContent: some View {
        if favorites.isEmpty {
            ContentUnavailableView {
                Label("No favorites yet", systemImage: "heart")
            } description: {
                Text("Tap the heart on a photo in the Inspiration tab to keep it here.")
            }
        } else if visibleFavorites.isEmpty {
            ContentUnavailableView("Nothing in this room", systemImage: "heart")
        } else {
            ScrollView {
                LazyVStack(spacing: 8) {
                    ForEach(Array(visibleFavorites.chunked(into: 6).enumerated()), id: \.offset) { _, block in
                        EqualizedMasonryLayout(aspectRatios: block.map { $0.asPexelsPhoto.aspectRatio }) {
                            ForEach(block) { favorite in
                                Button {
                                    selectedFavorite = favorite
                                } label: {
                                    PhotoCard(photo: favorite.asPexelsPhoto, isFavorite: true) {
                                        withAnimation(.snappy) {
                                            modelContext.delete(favorite)
                                        }
                                    }
                                }
                                .buttonStyle(.plain)
                                .accessibilityLabel(favorite.alt ?? "Photo by \(favorite.photographer)")
                            }
                        }
                    }
                }
                .padding(.horizontal, 8)
            }
        }
    }
}

#Preview {
    ProfileView()
        .modelContainer(for: [UserPhoto.self, FavoritePhoto.self], inMemory: true)
}
