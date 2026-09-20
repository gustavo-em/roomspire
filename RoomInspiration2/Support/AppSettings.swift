import SwiftUI

enum AppAppearance: String, CaseIterable, Identifiable {
    case system, light, dark

    static let storageKey = "appAppearance"

    var id: Self { self }

    static var current: AppAppearance {
        AppAppearance(rawValue: UserDefaults.standard.string(forKey: storageKey) ?? "") ?? .system
    }

    var title: LocalizedStringKey {
        switch self {
        case .system: "System"
        case .light: "Light"
        case .dark: "Dark"
        }
    }

    var interfaceStyle: UIUserInterfaceStyle {
        switch self {
        case .system: .unspecified
        case .light: .light
        case .dark: .dark
        }
    }
}

extension Notification.Name {
    static let appSettingsDidChange = Notification.Name("appSettingsDidChange")
}

struct AppRoot<Content: View>: View {
    @AppStorage(AppLanguage.storageKey) private var language = AppLanguage.system.rawValue
    @AppStorage(AppAppearance.storageKey) private var appearance = AppAppearance.system.rawValue
    @ViewBuilder let content: () -> Content

    var body: some View {
        content()
            .id(language)
            .environment(\.locale, (AppLanguage(rawValue: language) ?? .system).locale)
            .onChange(of: language) { notify() }
            .onChange(of: appearance) { notify() }
    }

    private func notify() {
        NotificationCenter.default.post(name: .appSettingsDidChange, object: nil)
    }
}
