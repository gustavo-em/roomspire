import SwiftUI

enum RoomType: String, CaseIterable, Identifiable {
    case livingRoom, kitchen, bedroom, bathroom, homeOffice, dining, balcony

    var id: Self { self }

    var title: String {
        switch self {
        case .livingRoom: localized("Living room")
        case .kitchen: localized("Kitchen")
        case .bedroom: localized("Bedroom")
        case .bathroom: localized("Bathroom")
        case .homeOffice: localized("Home office")
        case .dining: localized("Dining")
        case .balcony: localized("Balcony")
        }
    }

    var symbolName: String {
        switch self {
        case .livingRoom: "sofa"
        case .kitchen: "refrigerator"
        case .bedroom: "bed.double"
        case .bathroom: "shower"
        case .homeOffice: "desktopcomputer"
        case .dining: "fork.knife"
        case .balcony: "sun.max"
        }
    }

    var query: String {
        switch self {
        case .livingRoom: "living room interior"
        case .kitchen: "kitchen interior"
        case .bedroom: "bedroom interior"
        case .bathroom: "bathroom interior"
        case .homeOffice: "home office desk"
        case .dining: "dining room"
        case .balcony: "balcony decor"
        }
    }
}

enum DecorStyle: String, CaseIterable, Identifiable {
    case minimalist, scandinavian, industrial, rustic, boho, modern

    var id: Self { self }

    var title: String {
        switch self {
        case .minimalist: localized("Minimalist")
        case .scandinavian: localized("Scandinavian")
        case .industrial: localized("Industrial")
        case .rustic: localized("Rustic")
        case .boho: localized("Boho")
        case .modern: localized("Modern")
        }
    }

    var query: String {
        rawValue
    }
}

enum PhotoColor: String, CaseIterable, Identifiable {
    case white, gray, black, brown, red, orange, yellow, green, turquoise, blue, violet, pink

    var id: Self { self }

    var title: String {
        switch self {
        case .white: localized("White")
        case .gray: localized("Gray")
        case .black: localized("Black")
        case .brown: localized("Brown")
        case .red: localized("Red")
        case .orange: localized("Orange")
        case .yellow: localized("Yellow")
        case .green: localized("Green")
        case .turquoise: localized("Turquoise")
        case .blue: localized("Blue")
        case .violet: localized("Violet")
        case .pink: localized("Pink")
        }
    }

    var swatch: Color {
        switch self {
        case .white: .white
        case .gray: .gray
        case .black: .black
        case .brown: .brown
        case .red: .red
        case .orange: .orange
        case .yellow: .yellow
        case .green: .green
        case .turquoise: .teal
        case .blue: .blue
        case .violet: .purple
        case .pink: .pink
        }
    }
}

struct SearchCriteria: Equatable {
    var text = ""
    var room: RoomType?
    var style: DecorStyle?
    var color: PhotoColor?

    var pexelsQuery: String {
        let terms = [text.trimmingCharacters(in: .whitespacesAndNewlines), style?.query, room?.query]
            .compactMap { $0 }
            .filter { !$0.isEmpty }
        return terms.isEmpty ? "interior design" : terms.joined(separator: " ")
    }

    var isEmpty: Bool {
        text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty && room == nil && style == nil && color == nil
    }
}
