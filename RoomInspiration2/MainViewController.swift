import UIKit
import SwiftUI
import SwiftData

class MainViewController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()

        let highlights = UIHostingController(rootView: HighlightsView().modelContainer(Persistence.container))
        highlights.tabBarItem = UITabBarItem(title: "Inspiration", image: UIImage(systemName: "sparkles"), tag: 0)

        let profile = UIHostingController(rootView: ProfileView().modelContainer(Persistence.container))
        profile.tabBarItem = UITabBarItem(title: "Profile", image: UIImage(systemName: "person.crop.circle"), tag: 1)

        let appearance = UITabBarAppearance()
        appearance.configureWithDefaultBackground()
        tabBar.standardAppearance = appearance
        tabBar.scrollEdgeAppearance = appearance
        tabBar.tintColor = .systemRed
        tabBar.unselectedItemTintColor = .gray

        viewControllers = [highlights, profile]
    }
}
