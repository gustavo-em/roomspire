import UIKit
import SwiftUI
import SwiftData

class MainViewController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()

        let highlights = UIHostingController(rootView: AppRoot { HighlightsView() }.modelContainer(Persistence.container))
        highlights.tabBarItem = UITabBarItem(title: nil, image: UIImage(systemName: "sparkles"), tag: 0)

        let profile = UIHostingController(rootView: AppRoot { ProfileView() }.modelContainer(Persistence.container))
        profile.tabBarItem = UITabBarItem(title: nil, image: UIImage(systemName: "person.crop.circle"), tag: 1)

        let appearance = UITabBarAppearance()
        appearance.configureWithDefaultBackground()
        tabBar.standardAppearance = appearance
        tabBar.scrollEdgeAppearance = appearance
        tabBar.tintColor = UIColor(named: "AccentColor")
        tabBar.unselectedItemTintColor = .gray

        viewControllers = [highlights, profile]
        applySettings()

        NotificationCenter.default.addObserver(self, selector: #selector(applySettings), name: .appSettingsDidChange, object: nil)
    }

    @objc private func applySettings() {
        overrideUserInterfaceStyle = AppAppearance.current.interfaceStyle
        viewControllers?[0].tabBarItem.title = localized("Inspiration")
        viewControllers?[1].tabBarItem.title = localized("Profile")
    }
}
