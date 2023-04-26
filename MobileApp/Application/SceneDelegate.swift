//
//  SceneDelegate.swift
//  MobileApp
//
//  Created by Evgenii Mikhailov on 19.04.2023.
//

import UIKit
import Network

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    
    var window: UIWindow?
    let monitor = NWPathMonitor()
    
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowsScene = (scene as? UIWindowScene) else { return }
        let window = UIWindow(windowScene: windowsScene)
        
        Task {
            let isConnected = await checkInternetConnection()
            if isConnected {
                if AppDependencyClass.shared.authManager.loadAccessToken() {
                    let isValid = await AppDependencyClass.shared.authManager.testTokenValidity()
                    if isValid {
                        setAuthorizedRootViewController(window: window)
                    } else {
                        setUnauthorizedRootViewController(window: window)
                    }
                } else {
                    setUnauthorizedRootViewController(window: window)
                }
            } else {
                showNoInternetConnectionAlert(window: window)
            }
        }
        window.makeKeyAndVisible()
        self.window = window
    }
    
    private func setAuthorizedRootViewController(window: UIWindow) {
        DispatchQueue.main.async {
            let viewModel = AppDependencyClass.shared.photosViewModel
            let photosViewController = PhotosViewController(viewModel: viewModel)
            let nav = UINavigationController(rootViewController: photosViewController)
            window.rootViewController = nav
        }
    }
    
    private func setUnauthorizedRootViewController(window: UIWindow) {
        DispatchQueue.main.async {
            let authManager = AppDependencyClass.shared.authManager
            let loginViewController = LoginViewController(authManager: authManager)
            window.rootViewController = loginViewController
        }
    }
    
    private func showNoInternetConnectionAlert(window: UIWindow) {
        DispatchQueue.main.async {
            let navigationController = UINavigationController(rootViewController: LaunchScreenViewController())
            let alertController = UIAlertController(title: NSLocalizedString("alert_network_title", comment: ""),
                                                    message: NSLocalizedString("alert_network_message", comment: ""), preferredStyle: .alert)
            alertController.addAction(UIAlertAction(title: NSLocalizedString("alert_network_confirm", comment: ""), style: .default, handler: nil))
            window.rootViewController = navigationController
            navigationController.present(alertController, animated: true, completion: nil)
        }
    }
    
    private func checkInternetConnection() async -> Bool {
        return await withCheckedContinuation { continuation in
            monitor.pathUpdateHandler = { path in
                if path.status == .satisfied {
                    print("Connected to the Internet")
                    continuation.resume(returning: true)
                } else {
                    continuation.resume(returning: false)
                }
            }
            let queue = DispatchQueue(label: "Monitor")
            monitor.start(queue: queue)
        }
    }
    
    func sceneDidDisconnect(_ scene: UIScene) {
        // Called as the scene is being released by the system.
        // This occurs shortly after the scene enters the background, or when its session is discarded.
        // Release any resources associated with this scene that can be re-created the next time the scene connects.
        // The scene may re-connect later, as its session was not necessarily discarded (see `application:didDiscardSceneSessions` instead).
    }
    
    func sceneDidBecomeActive(_ scene: UIScene) {
        // Called when the scene has moved from an inactive state to an active state.
        // Use this method to restart any tasks that were paused (or not yet started) when the scene was inactive.
    }
    
    func sceneWillResignActive(_ scene: UIScene) {
        // Called when the scene will move from an active state to an inactive state.
        // This may occur due to temporary interruptions (ex. an incoming phone call).
    }
    
    func sceneWillEnterForeground(_ scene: UIScene) {
    }
    
    func sceneDidEnterBackground(_ scene: UIScene) {
        // Called as the scene transitions from the foreground to the background.
        // Use this method to save data, release shared resources, and store enough scene-specific state information
        // to restore the scene back to its current state.
    }
}
