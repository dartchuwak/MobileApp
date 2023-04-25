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
    
    let authManager = AuthManager.shared
    
    
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowsScene = (scene as? UIWindowScene) else { return }
        let window = UIWindow(windowScene: windowsScene)
        let navigationController = UINavigationController(rootViewController: LaunchScreenViewController())
        
        checkInternetConnection { isConnected in
            
            if isConnected { //Проверка наличия сети
                
                //Попытка получения токена из Keychain, если уже авторизировались
                if self.authManager.loadAccessToken() {
                    Task {
                        //Проверка токена на валидность
                        let isValid = await self.authManager.testTokenValidity()
                        if isValid {
                            DispatchQueue.main.async {
                                let photosViewController = PhotosViewController(viewModel: AppDependency.shared.photosViewModel)
                                let nav = UINavigationController(rootViewController: photosViewController)
                                window.rootViewController = nav
                            }
                        } else {
                            // Если токен не валиден, то открываем стартовый экран для новой авторизации
                            DispatchQueue.main.async { [weak self] in
                                guard let self = self else { return }
                                let loginViewController = LoginViewController(authManager: self.authManager)
                                window.rootViewController = loginViewController
                            }
                        }
                    }
                } else {
                    //Если токена в keychain нет, то открываем начальный экран
                    DispatchQueue.main.async {
                        let loginViewController = LoginViewController(authManager: self.authManager)
                        window.rootViewController = loginViewController
                    }
                }
            } else { // Если сети нет, выкидывем alert
                DispatchQueue.main.async {
                    let alertController = UIAlertController(title: NSLocalizedString("alert_network_title", comment: ""), message: NSLocalizedString("alert_network_message", comment: ""), preferredStyle: .alert)
                    alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                    window.rootViewController = navigationController
                    navigationController.present(alertController, animated: true, completion: nil)
                }
            }
        }
        window.makeKeyAndVisible()
        self.window = window
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
    
    private func checkInternetConnection(completion: @escaping (Bool) -> Void) {
        monitor.pathUpdateHandler = { path in
            if path.status == .satisfied {
                print("Connected to the Internet")
                completion(true)
            } else {
                completion(false)
            }
        }
        
        let queue = DispatchQueue(label: "Monitor")
        monitor.start(queue: queue)
    }
}







