import AppKit

struct Slide {
    let raw: String
    let headline: [String: String]
    let calloutTitle: [String: String]
    let calloutSubtitle: [String: String]
    let ground: NSColor
    let headlineColor: NSColor
    let showsBrand: Bool
    let colorDots: Bool
}

let terracotta = NSColor(srgbRed: 0.85, green: 0.38, blue: 0.24, alpha: 1)
let amber = NSColor(srgbRed: 0.96, green: 0.65, blue: 0.35, alpha: 1)
let ink = NSColor(srgbRed: 0.11, green: 0.11, blue: 0.11, alpha: 1)
let cream = NSColor(srgbRed: 0.98, green: 0.96, blue: 0.93, alpha: 1)

let slides: [Slide] = [
    Slide(raw: "feed.png",
          headline: ["en": "Ideas for\nevery room.", "pt-BR": "Ideias para\ncada cômodo."],
          calloutTitle: ["en": "Living room · Minimalist", "pt-BR": "Sala · Minimalista"],
          calloutSubtitle: ["en": "Filters you can combine", "pt-BR": "Filtros que se combinam"],
          ground: terracotta, headlineColor: cream, showsBrand: true, colorDots: false),
    Slide(raw: "filters.png",
          headline: ["en": "Room, style\nand colour.", "pt-BR": "Cômodo, estilo\ne cor."],
          calloutTitle: ["en": "Blue", "pt-BR": "Azul"],
          calloutSubtitle: ["en": "Twelve colours straight from the photo", "pt-BR": "Doze cores direto da foto"],
          ground: ink, headlineColor: amber, showsBrand: false, colorDots: true),
    Slide(raw: "favorites.png",
          headline: ["en": "Keep what\nyou love.", "pt-BR": "Guarde o que\nvocê ama."],
          calloutTitle: ["en": "Saved to favorites", "pt-BR": "Salvo nos favoritos"],
          calloutSubtitle: ["en": "Tagged with the room you were browsing", "pt-BR": "Com o cômodo que você estava vendo"],
          ground: cream, headlineColor: ink, showsBrand: false, colorDots: false),
    Slide(raw: "rooms.png",
          headline: ["en": "Your rooms,\ntagged.", "pt-BR": "Seus ambientes,\ncom etiqueta."],
          calloutTitle: ["en": "Bedroom · Scandinavian", "pt-BR": "Quarto · Escandinavo"],
          calloutSubtitle: ["en": "Stored on your iPhone, nowhere else", "pt-BR": "Guardado no seu iPhone, em mais nenhum lugar"],
          ground: terracotta, headlineColor: cream, showsBrand: false, colorDots: false),
    Slide(raw: "dark.png",
          headline: ["en": "Dark mode.\nTwo languages.", "pt-BR": "Modo escuro.\nDois idiomas."],
          calloutTitle: ["en": "English · Português", "pt-BR": "English · Português"],
          calloutSubtitle: ["en": "Switch either one inside the app", "pt-BR": "Troque os dois dentro do app"],
          ground: ink, headlineColor: cream, showsBrand: false, colorDots: false),
]

struct Device {
    let canvas: NSSize
    let frameRadius: CGFloat
}

let devices: [String: Device] = [
    "iphone-6.5": Device(canvas: NSSize(width: 1284, height: 2778), frameRadius: 0.114),
    "ipad-13": Device(canvas: NSSize(width: 2064, height: 2752), frameRadius: 0.05),
]

let args = CommandLine.arguments
guard args.count == 5, let device = devices[args[1]] else {
    print("usage: generate-store-screenshots.swift <iphone-6.5|ipad-13> <raw dir> <logo.png> <out dir>")
    exit(1)
}
let canvas = device.canvas
let rawDir = args[2], logoPath = args[3], outDir = args[4]
let unit = canvas.width / 1320

func rect(_ x: CGFloat, _ top: CGFloat, _ w: CGFloat, _ h: CGFloat) -> NSRect {
    NSRect(x: x, y: canvas.height - top - h, width: w, height: h)
}

func draw(_ text: String, in frame: NSRect, size: CGFloat, weight: NSFont.Weight, color: NSColor, lineHeight: CGFloat? = nil) {
    let paragraph = NSMutableParagraphStyle()
    if let lineHeight {
        paragraph.minimumLineHeight = lineHeight
        paragraph.maximumLineHeight = lineHeight
    }
    let attributes: [NSAttributedString.Key: Any] = [
        .font: NSFont.systemFont(ofSize: size, weight: weight),
        .foregroundColor: color,
        .paragraphStyle: paragraph,
        .kern: size * -0.03,
    ]
    (text as NSString).draw(with: frame, options: [.usesLineFragmentOrigin], attributes: attributes)
}

func tinted(_ symbolName: String, size: CGFloat, color: NSColor) -> NSImage? {
    let config = NSImage.SymbolConfiguration(pointSize: size, weight: .bold)
    guard let symbol = NSImage(systemSymbolName: symbolName, accessibilityDescription: nil)?.withSymbolConfiguration(config) else { return nil }
    let image = NSImage(size: symbol.size)
    image.lockFocus()
    symbol.draw(in: NSRect(origin: .zero, size: symbol.size))
    color.setFill()
    NSRect(origin: .zero, size: symbol.size).fill(using: .sourceAtop)
    image.unlockFocus()
    return image
}

func flattened(_ bitmap: NSBitmapImageRep) -> NSBitmapImageRep {
    let width = bitmap.pixelsWide, height = bitmap.pixelsHigh
    let context = CGContext(data: nil, width: width, height: height, bitsPerComponent: 8, bytesPerRow: 0, space: CGColorSpaceCreateDeviceRGB(), bitmapInfo: CGImageAlphaInfo.noneSkipLast.rawValue)!
    context.draw(bitmap.cgImage!, in: CGRect(x: 0, y: 0, width: width, height: height))
    return NSBitmapImageRep(cgImage: context.makeImage()!)
}

func render(_ slide: Slide, language: String, index: Int) {
    guard let shot = NSImage(contentsOfFile: "\(rawDir)/\(language)/\(slide.raw)") else {
        print("missing \(language)/\(slide.raw)")
        return
    }
    let bitmap = NSBitmapImageRep(bitmapDataPlanes: nil, pixelsWide: Int(canvas.width), pixelsHigh: Int(canvas.height), bitsPerSample: 8, samplesPerPixel: 4, hasAlpha: true, isPlanar: false, colorSpaceName: .deviceRGB, bytesPerRow: 0, bitsPerPixel: 0)!
    NSGraphicsContext.saveGraphicsState()
    let context = NSGraphicsContext(bitmapImageRep: bitmap)!
    NSGraphicsContext.current = context
    context.imageInterpolation = .high

    slide.ground.setFill()
    NSRect(origin: .zero, size: canvas).fill()

    var headlineTop: CGFloat = 300 * unit
    if slide.showsBrand, let logo = NSImage(contentsOfFile: logoPath) {
        logo.draw(in: rect(96 * unit, 150 * unit, 120 * unit, 120 * unit), from: .zero, operation: .sourceOver, fraction: 1)
        draw("Roomspire", in: rect(240 * unit, 168 * unit, 700 * unit, 100 * unit), size: 68 * unit, weight: .heavy, color: slide.headlineColor)
        headlineTop = 360 * unit
    }
    draw(slide.headline[language]!, in: rect(96 * unit, headlineTop, canvas.width - 160 * unit, 520 * unit), size: 150 * unit, weight: .black, color: slide.headlineColor, lineHeight: 160 * unit)

    let phoneWidth: CGFloat = 1240 * unit
    let shotRatio = shot.size.height / shot.size.width
    let bezel: CGFloat = 26 * unit
    let phoneHeight = (phoneWidth - bezel * 2) * shotRatio + bezel * 2
    let phoneFrame = rect(200 * unit, 1010 * unit, phoneWidth, phoneHeight)
    let radius = device.frameRadius * canvas.width

    NSGraphicsContext.saveGraphicsState()
    let pivot = NSPoint(x: phoneFrame.midX, y: phoneFrame.midY)
    let transform = NSAffineTransform()
    transform.translateX(by: pivot.x, yBy: pivot.y)
    transform.rotate(byDegrees: 6)
    transform.translateX(by: -pivot.x, yBy: -pivot.y)
    transform.concat()

    let shadow = NSShadow()
    shadow.shadowColor = NSColor.black.withAlphaComponent(0.35)
    shadow.shadowBlurRadius = 60 * unit
    shadow.shadowOffset = NSSize(width: 0, height: -30 * unit)
    shadow.set()
    ink.setFill()
    NSBezierPath(roundedRect: phoneFrame, xRadius: radius, yRadius: radius).fill()
    NSShadow().set()

    let screen = phoneFrame.insetBy(dx: bezel, dy: bezel)
    NSGraphicsContext.saveGraphicsState()
    NSBezierPath(roundedRect: screen, xRadius: radius - bezel, yRadius: radius - bezel).addClip()
    shot.draw(in: screen, from: .zero, operation: .sourceOver, fraction: 1)
    NSGraphicsContext.restoreGraphicsState()
    NSGraphicsContext.restoreGraphicsState()

    let card = rect(72 * unit, 1560 * unit, 840 * unit, 220 * unit)
    let cardShadow = NSShadow()
    cardShadow.shadowColor = NSColor.black.withAlphaComponent(0.28)
    cardShadow.shadowBlurRadius = 50 * unit
    cardShadow.shadowOffset = NSSize(width: 0, height: -20 * unit)
    cardShadow.set()
    NSColor.white.setFill()
    NSBezierPath(roundedRect: card, xRadius: 44 * unit, yRadius: 44 * unit).fill()
    NSShadow().set()

    var textLeft = card.minX + 48 * unit
    if slide.colorDots {
        let dots: [NSColor] = [.white, .systemGray, .black, .systemBrown, .systemRed, .systemOrange, .systemGreen, .systemBlue]
        for (i, color) in dots.enumerated() {
            let dot = NSRect(x: card.minX + (48 + CGFloat(i) * 60) * unit, y: card.maxY - 102 * unit, width: 44 * unit, height: 44 * unit)
            color.setFill()
            NSBezierPath(ovalIn: dot).fill()
            NSColor.black.withAlphaComponent(0.15).setStroke()
            NSBezierPath(ovalIn: dot).stroke()
            if i == dots.count - 1 {
                terracotta.setStroke()
                let ring = NSBezierPath(ovalIn: dot.insetBy(dx: -6 * unit, dy: -6 * unit))
                ring.lineWidth = 6 * unit
                ring.stroke()
            }
        }
        draw(slide.calloutTitle[language]!, in: NSRect(x: card.minX + 552 * unit, y: card.maxY - 108 * unit, width: 300 * unit, height: 60 * unit), size: 40 * unit, weight: .bold, color: ink)
        draw(slide.calloutSubtitle[language]!, in: NSRect(x: card.minX + 48 * unit, y: card.minY + 36 * unit, width: card.width - 96 * unit, height: 60 * unit), size: 34 * unit, weight: .medium, color: NSColor.black.withAlphaComponent(0.55))
    } else {
        let symbolName = slide.raw == "favorites.png" ? "heart.fill" : (slide.raw == "dark.png" ? "globe" : "sofa.fill")
        if let icon = tinted(symbolName, size: 44 * unit, color: terracotta) {
            let badge = NSRect(x: card.minX + 44 * unit, y: card.midY - 44 * unit, width: 88 * unit, height: 88 * unit)
            terracotta.withAlphaComponent(0.14).setFill()
            NSBezierPath(ovalIn: badge).fill()
            icon.draw(in: NSRect(x: badge.midX - icon.size.width / 2, y: badge.midY - icon.size.height / 2, width: icon.size.width, height: icon.size.height), from: .zero, operation: .sourceOver, fraction: 1)
            textLeft = badge.maxX + 32 * unit
        }
        draw(slide.calloutTitle[language]!, in: NSRect(x: textLeft, y: card.midY + 8 * unit, width: card.maxX - textLeft - 40 * unit, height: 70 * unit), size: 44 * unit, weight: .bold, color: ink)
        draw(slide.calloutSubtitle[language]!, in: NSRect(x: textLeft, y: card.midY - 62 * unit, width: card.maxX - textLeft - 40 * unit, height: 60 * unit), size: 32 * unit, weight: .medium, color: NSColor.black.withAlphaComponent(0.55))
    }

    NSGraphicsContext.restoreGraphicsState()
    let data = flattened(bitmap).representation(using: .png, properties: [:])!
    let name = String(format: "%02d-%@.png", index + 1, slide.raw.replacingOccurrences(of: ".png", with: ""))
    try! FileManager.default.createDirectory(atPath: "\(outDir)/\(language)", withIntermediateDirectories: true)
    try! data.write(to: URL(fileURLWithPath: "\(outDir)/\(language)/\(name)"))
    print("wrote \(language)/\(name)")
}

for language in ["en", "pt-BR"] {
    for (index, slide) in slides.enumerated() {
        render(slide, language: language, index: index)
    }
}
