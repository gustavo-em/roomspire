import SwiftUI
import SwiftData

struct UserPhotoDetailView: View {
    @Bindable var photo: UserPhoto
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @State private var image: UIImage?
    @State private var showDeleteConfirmation = false

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    Color(hex: photo.averageColorHex)
                        .aspectRatio(photo.aspectRatio, contentMode: .fit)
                        .overlay {
                            if let image {
                                Image(uiImage: image).resizable().scaledToFill()
                            }
                        }
                        .clipped()
                        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))

                    HStack(spacing: 8) {
                        if let room = photo.room {
                            Label(room.title, systemImage: room.symbolName)
                        }
                        if let style = photo.style {
                            Text(style.title)
                        }
                    }
                    .font(.subheadline.weight(.medium))
                    .foregroundStyle(.secondary)

                    TextField("Note", text: $photo.note, axis: .vertical)
                        .textFieldStyle(.roundedBorder)

                    Text(photo.createdAt, format: .dateTime.day().month(.wide).year())
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }
                .padding()
            }
            .navigationTitle(photo.room?.title ?? "My room")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") { dismiss() }
                }
                ToolbarItem(placement: .destructiveAction) {
                    Button("Delete", systemImage: "trash", role: .destructive) {
                        showDeleteConfirmation = true
                    }
                }
            }
            .confirmationDialog("Delete this photo?", isPresented: $showDeleteConfirmation, titleVisibility: .visible) {
                Button("Delete", role: .destructive) {
                    modelContext.delete(photo)
                    dismiss()
                }
            }
            .task {
                image = await ImageProcessor.decodeForDisplay(photo.imageData)
            }
        }
    }
}
