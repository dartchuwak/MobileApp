//
//  SceneDelegate.swift
//  MobileApp
//
//  Created by Evgenii Mikhailov on 19.04.2023.
//

import UIKit
import SwiftUI
import Network

let appDependency = AppDependency(loginViewModel: LoginViewModel(),
                                  photosViewModel: PhotosViewModel(networkManager: NetworkManager()),
                                  networkManager: NetworkManager())

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    
    var window: UIWindow?
    let monitor = NWPathMonitor()
    
    
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowsScene = (scene as? UIWindowScene) else { return }
        let window = UIWindow(windowScene: windowsScene)
        let navigationController = UINavigationController()
        navigationController.setViewControllers([LaunchScreenViewController()], animated: false)
        
        checkInternetConnection { [weak self] isConnected in
//            guard let self = self  else { return }
            if isConnected {
                if let token = appDependency.loginViewModel.loadAccessToken() {
                    Task {
                        do {
                            let isValid = try await appDependency.networkManager.checkTokenValidity(accessToken: token)
                            if isValid {
                                appDependency.loginViewModel.token = token
                                appDependency.photosViewModel.token = token
                                let photosViewController = PhotosViewController(viewModel: (appDependency.photosViewModel))
                                navigationController.setViewControllers([photosViewController], animated: false)
                            } else {
                                let loginViewController = StartViewController(dep: appDependency)
                                navigationController.setViewControllers([loginViewController], animated: false)
                            }
                        } catch {
                            //Need to catch here smth
                        }
                    }
                } else {
                    
                    DispatchQueue.main.async {
                        let loginViewController = StartViewController(dep: appDependency)
                        navigationController.setViewControllers([loginViewController], animated: false)
                    }
                }
            } else {
                let alertController = UIAlertController(title: "No Internet Connection", message: "Please check your internet connection and try again.", preferredStyle: .alert)
                alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                DispatchQueue.main.async {
                    navigationController.present(alertController, animated: true, completion: nil)
                }
            }
        }
        window.rootViewController =  navigationController
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
    
    func checkInternetConnection(completion: @escaping (Bool) -> Void) {
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







