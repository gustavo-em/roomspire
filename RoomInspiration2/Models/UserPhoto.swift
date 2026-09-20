import Foundation
import SwiftData

@Model
final class UserPhoto {
    @Attribute(.externalStorage) var imageData: Data
    var width: Int
    var height: Int
    var averageColorHex: String
    var roomRawValue: String?
    var styleRawValue: String?
    var note: String
    var createdAt: Date

    init(imageData: Data, width: Int, height: Int, averageColorHex: String,
         room: RoomType?, style: DecorStyle?, note: String) {
        self.imageData = imageData
        self.width = width
        self.height = height
        self.averageColorHex = averageColorHex
        self.roomRawValue = room?.rawValue
        self.styleRawValue = style?.rawValue
        self.note = note
        self.createdAt = .now
    }

    var room: RoomType? {
        get { roomRawValue.flatMap(RoomType.init(rawValue:)) }
        set { roomRawValue = newValue?.rawValue }
    }

    var style: DecorStyle? {
        get { styleRawValue.flatMap(DecorStyle.init(rawValue:)) }
        set { styleRawValue = newValue?.rawValue }
    }

    var aspectRatio: CGFloat {
        CGFloat(width) / CGFloat(max(height, 1))
    }
}
