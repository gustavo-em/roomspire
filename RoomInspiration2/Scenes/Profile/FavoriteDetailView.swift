import SwiftUI
import SwiftData

struct FavoriteDetailView: View {
    let favorite: FavoritePhoto
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    Color(hex: favorite.averageColorHex ?? "#9E9E9E")
                        .aspectRatio(favorite.asPexelsPhoto.aspectRatio, contentMode: .fit)
                        .overlay {
                            AsyncImage(url: favorite.largeURL) { image in
                                image.resizable().scaledToFill()
                            } placeholder: {
                                Color.clear
                            }
                        }
                        .clipped()
                        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))

                    HStack(spacing: 8) {
                        if let room = favorite.room {
                            Label(room.title, systemImage: room.symbolName)
                        }
                        if let style = favorite.style {
                            Text(style.title)
                        }
                    }
                    .font(.subheadline.weight(.medium))
                    .foregroundStyle(.secondary)

                    if let alt = favorite.alt, !alt.isEmpty {
                        Text(alt)
                    }

                    Text("Photo by \(favorite.photographer)")
                        .font(.footnote)
                        .foregroundStyle(.secondary)

                    HStack(spacing: 12) {
                        Link(destination: favorite.pageURL) {
                            Label("View on Pexels", systemImage: "arrow.up.right.square")
                                .frame(maxWidth: .infinity)
                        }
                        .buttonStyle(.bordered)

                        ShareLink(item: favorite.pageURL) {
                            Label("Share", systemImage: "square.and.arrow.up")
                                .frame(maxWidth: .infinity)
                        }
                        .buttonStyle(.bordered)
                    }

                    Button(role: .destructive) {
                        modelContext.delete(favorite)
                        dismiss()
                    } label: {
                        Label("Remove from favorites", systemImage: "heart.slash")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.bordered)
                }
                .padding()
            }
            .navigationTitle(favorite.room?.title ?? "Favorite")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") { dismiss() }
                }
            }
        }
    }
}
