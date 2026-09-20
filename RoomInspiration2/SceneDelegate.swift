import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {

        guard let _scene = (scene as? UIWindowScene) else { return }
        let window = UIWindow(windowScene: _scene)
        let viewController = MainViewController()
        viewController.view.backgroundColor = .systemBackground
        window.rootViewController = viewController
        window.makeKeyAndVisible()
        self.window = window

    }

}
