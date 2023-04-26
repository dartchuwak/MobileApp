//
//  App.swift
//  MobileApp
//
//  Created by Evgenii Mikhailov on 20.04.2023.
//

import Foundation

class AppDependencyClass {
    
    static let shared = AppDependencyClass()
    private init(){}
    private (set) lazy var networkManager: NetworkManagerProtocol = NetworkManager()
    private (set) lazy var authManager: AuthManagerProtocol = AuthManager(networkManager: networkManager)
    private (set) lazy var photosViewModel = PhotosViewModel(networkManager: networkManager, authManager: authManager)

}

class AppDependency {
    
}

class AppDependencyContainer {
    let authManager: AuthManagerProtocol
    let photosViewModel: PhotosViewModel
    let networkManager: NetworkManagerProtocol
    
    init(networkManager: NetworkManagerProtocol, authManager: AuthManagerProtocol, photosViewModel: PhotosViewModel) {
        self.authManager = authManager
        self.photosViewModel = photosViewModel
        self.networkManager = networkManager
    }
}
