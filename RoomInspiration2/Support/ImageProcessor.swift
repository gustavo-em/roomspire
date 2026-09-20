import UIKit

nonisolated struct ProcessedImage: Sendable {
    let jpegData: Data
    let width: Int
    let height: Int
    let averageColorHex: String
}

nonisolated enum ImageProcessor {

    static func process(_ data: Data, maxPixelSize: CGFloat = 1600) async -> ProcessedImage? {
        guard let original = UIImage(data: data) else { return nil }

        let scale = min(1, maxPixelSize / max(original.size.width, original.size.height))
        let targetSize = CGSize(width: original.size.width * scale, height: original.size.height * scale)

        guard let resized = await original.byPreparingThumbnail(ofSize: targetSize),
              let jpeg = resized.jpegData(compressionQuality: 0.85) else { return nil }

        return ProcessedImage(
            jpegData: jpeg,
            width: Int(resized.size.width * resized.scale),
            height: Int(resized.size.height * resized.scale),
            averageColorHex: averageColorHex(of: resized) ?? "#9E9E9E"
        )
    }

    static func decodeForDisplay(_ data: Data) async -> UIImage? {
        guard let image = UIImage(data: data) else { return nil }
        return await image.byPreparingForDisplay() ?? image
    }

    static func averageColorHex(of image: UIImage) -> String? {
        guard let cgImage = image.cgImage else { return nil }
        var pixel = [UInt8](repeating: 0, count: 4)
        let drawn = pixel.withUnsafeMutableBytes { buffer -> Bool in
            guard let context = CGContext(
                data: buffer.baseAddress,
                width: 1, height: 1,
                bitsPerComponent: 8, bytesPerRow: 4,
                space: CGColorSpaceCreateDeviceRGB(),
                bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue
            ) else { return false }
            context.interpolationQuality = .high
            context.draw(cgImage, in: CGRect(x: 0, y: 0, width: 1, height: 1))
            return true
        }
        guard drawn else { return nil }
        return String(format: "#%02X%02X%02X", pixel[0], pixel[1], pixel[2])
    }
}
