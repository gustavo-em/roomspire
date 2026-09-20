import SwiftUI

enum AppLanguage: String, CaseIterable, Identifiable {
    case system
    case english = "en"
    case portuguese = "pt-BR"

    static let storageKey = "appLanguage"

    var id: Self { self }

    static var current: AppLanguage {
        AppLanguage(rawValue: UserDefaults.standard.string(forKey: storageKey) ?? "") ?? .system
    }

    var title: Text {
        switch self {
        case .system: Text("System")
        case .english: Text(verbatim: "English")
        case .portuguese: Text(verbatim: "Português")
        }
    }

    var locale: Locale {
        self == .system ? .autoupdatingCurrent : Locale(identifier: rawValue)
    }

    var bundle: Bundle {
        switch self {
        case .system: .main
        case .english: Self.bundle(named: "en") ?? Self.bundle(named: "Base") ?? .main
        case .portuguese: Self.bundle(named: rawValue) ?? .main
        }
    }

    private static func bundle(named name: String) -> Bundle? {
        Bundle.main.path(forResource: name, ofType: "lproj").flatMap(Bundle.init(path:))
    }
}

func localized(_ key: String.LocalizationValue) -> String {
    String(localized: key, bundle: AppLanguage.current.bundle)
}
