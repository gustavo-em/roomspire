import SwiftUI
import PhotosUI
import SwiftData

struct AddPhotoView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    @State private var selectedItem: PhotosPickerItem?
    @State private var pickedData: Data?
    @State private var preview: UIImage?
    @State private var room: RoomType?
    @State private var style: DecorStyle?
    @State private var note = ""
    @State private var isSaving = false

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    PhotosPicker(selection: $selectedItem, matching: .images) {
                        if let preview {
                            Image(uiImage: preview)
                                .resizable()
                                .scaledToFill()
                                .frame(maxWidth: .infinity)
                                .frame(height: 240)
                                .clipped()
                                .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                        } else {
                            Label("Choose from library", systemImage: "photo.on.rectangle.angled")
                                .frame(maxWidth: .infinity, minHeight: 120)
                        }
                    }
                    .listRowInsets(EdgeInsets())
                    .listRowBackground(Color.clear)
                }

                Section("Details") {
                    Picker("Room", selection: $room) {
                        Text("Not set").tag(RoomType?.none)
                        ForEach(RoomType.allCases) { room in
                            Label(room.title, systemImage: room.symbolName).tag(Optional(room))
                        }
                    }
                    Picker("Style", selection: $style) {
                        Text("Not set").tag(DecorStyle?.none)
                        ForEach(DecorStyle.allCases) { style in
                            Text(style.title).tag(Optional(style))
                        }
                    }
                    TextField("Note (optional)", text: $note, axis: .vertical)
                        .lineLimit(2...4)
                }
            }
            .navigationTitle("New room")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        Task { await save() }
                    }
                    .disabled(pickedData == nil || isSaving)
                }
            }
            .onChange(of: selectedItem) { _, item in
                Task { await loadPicked(item) }
            }
            .overlay {
                if isSaving {
                    ProgressView("Saving…")
                        .padding()
                        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 12))
                }
            }
        }
    }

    private func loadPicked(_ item: PhotosPickerItem?) async {
        guard let item, let data = try? await item.loadTransferable(type: Data.self) else { return }
        pickedData = data
        preview = UIImage(data: data)
    }

    private func save() async {
        guard let pickedData else { return }
        isSaving = true
        defer { isSaving = false }

        guard let processed = await ImageProcessor.process(pickedData) else { return }

        let photo = UserPhoto(
            imageData: processed.jpegData,
            width: processed.width,
            height: processed.height,
            averageColorHex: processed.averageColorHex,
            room: room,
            style: style,
            note: note.trimmingCharacters(in: .whitespacesAndNewlines)
        )
        modelContext.insert(photo)
        dismiss()
    }
}

#Preview {
    AddPhotoView()
        .modelContainer(for: [UserPhoto.self, FavoritePhoto.self], inMemory: true)
}
