import SwiftUI

struct PhotoCard: View {
    let photo: PexelsPhoto
    var showsCaption = false
    var isFavorite = false
    var onFavoriteTap: (() -> Void)? = nil

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Color(hex: photo.averageColorHex ?? "#9E9E9E")
                .overlay {
                    AsyncImage(url: photo.src.large) { image in
                        image
                            .resizable()
                            .scaledToFill()
                    } placeholder: {
                        Color.clear
                    }
                }
                .clipped()
                .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                .overlay(alignment: .topTrailing) {
                    if let onFavoriteTap {
                        Button(action: onFavoriteTap) {
                            Image(systemName: isFavorite ? "heart.fill" : "heart")
                                .font(.system(size: 15, weight: .semibold))
                                .foregroundStyle(isFavorite ? .red : .white)
                                .padding(8)
                                .background(.ultraThinMaterial, in: Circle())
                                .contentTransition(.symbolEffect(.replace))
                        }
                        .buttonStyle(.plain)
                        .padding(8)
                        .accessibilityLabel(isFavorite ? "Remove from favorites" : "Add to favorites")
                    }
                }

            if showsCaption, let alt = photo.alt, !alt.isEmpty {
                Text(alt)
                    .font(.footnote.weight(.medium))
                    .lineLimit(1)
                    .padding(.horizontal, 4)
            }
        }
        .accessibilityElement(children: .contain)
        .accessibilityLabel("\(photo.alt ?? "Photo") by \(photo.photographer)")
    }
}
