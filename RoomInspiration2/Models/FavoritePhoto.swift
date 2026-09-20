import Foundation
import SwiftData

@Model
final class FavoritePhoto {
    #Unique<FavoritePhoto>([\.photoID])

    var photoID: Int
    var photographer: String
    var width: Int
    var height: Int
    var averageColorHex: String?
    var alt: String?
    var pageURL: URL
    var mediumURL: URL
    var largeURL: URL
    var roomRawValue: String?
    var styleRawValue: String?
    var savedAt: Date

    init(photo: PexelsPhoto, room: RoomType?, style: DecorStyle?) {
        self.photoID = photo.id
        self.photographer = photo.photographer
        self.width = photo.width
        self.height = photo.height
        self.averageColorHex = photo.averageColorHex
        self.alt = photo.alt
        self.pageURL = photo.url
        self.mediumURL = photo.src.medium
        self.largeURL = photo.src.large
        self.roomRawValue = room?.rawValue
        self.styleRawValue = style?.rawValue
        self.savedAt = .now
    }

    var room: RoomType? {
        get { roomRawValue.flatMap(RoomType.init(rawValue:)) }
        set { roomRawValue = newValue?.rawValue }
    }

    var style: DecorStyle? {
        get { styleRawValue.flatMap(DecorStyle.init(rawValue:)) }
        set { styleRawValue = newValue?.rawValue }
    }

    var asPexelsPhoto: PexelsPhoto {
        PexelsPhoto(
            id: photoID,
            photographer: photographer,
            width: width,
            height: height,
            averageColorHex: averageColorHex,
            alt: alt,
            url: pageURL,
            src: PexelsPhoto.Source(medium: mediumURL, large: largeURL)
        )
    }

    static func find(photoID: Int, in context: ModelContext) -> FavoritePhoto? {
        var descriptor = FetchDescriptor<FavoritePhoto>(predicate: #Predicate { $0.photoID == photoID })
        descriptor.fetchLimit = 1
        return try? context.fetch(descriptor).first
    }

    @discardableResult
    static func toggle(_ photo: PexelsPhoto, room: RoomType?, style: DecorStyle?, in context: ModelContext) -> Bool {
        if let existing = find(photoID: photo.id, in: context) {
            context.delete(existing)
            return false
        }
        context.insert(FavoritePhoto(photo: photo, room: room, style: style))
        return true
    }
}
