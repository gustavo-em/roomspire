import SwiftUI
import SwiftData

struct LocalPhotoCard: View {
    let photo: UserPhoto
    @State private var image: UIImage?

    var body: some View {
        Color(hex: photo.averageColorHex)
            .overlay {
                if let image {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFill()
                        .transition(.opacity)
                }
            }
            .clipped()
            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
            .overlay(alignment: .bottomLeading) {
                if let room = photo.room {
                    Label(room.title, systemImage: room.symbolName)
                        .font(.caption.weight(.semibold))
                        .padding(.horizontal, 8)
                        .padding(.vertical, 5)
                        .background(.thinMaterial, in: Capsule())
                        .padding(8)
                }
            }
            .task(id: photo.persistentModelID) {
                let decoded = await ImageProcessor.decodeForDisplay(photo.imageData)
                withAnimation(.easeOut(duration: 0.2)) { image = decoded }
            }
            .accessibilityLabel(photo.note.isEmpty ? (photo.room?.title ?? "Photo") : photo.note)
    }
}
