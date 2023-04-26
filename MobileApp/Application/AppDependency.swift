//
//  App.swift
//  MobileApp
//
//  Created by Evgenii Mikhailov on 20.04.2023.
//

import Foundation

class AppDependencyClass {
    
    static let shared = AppDependencyClass()
    
//    init(photosViewModel: PhotosViewModel, networkManager: NetworkManagerProtocol, authManager: AuthManagerProtocol) {
//        self.photosViewModel = photosViewModel
//        self.networkManager = networkManager
//        self.authManager = authManager
//    }
    
    
    private (set) lazy var networkManager: NetworkManagerProtocol = NetworkManager()
    private (set) lazy var authManager: AuthManagerProtocol = AuthManager()
    private (set) lazy var photosViewModel = PhotosViewModel(networkManager: networkManager, authManager: authManager)
    ///private (set) lazy var networkManager: NetworkManagerProtocol = NetworkManager()
    
//    static func configure() -> AppDependencyClass {
//        let networkManager = NetworkManager()
//        let authManager = AuthManager.shared
//        let photosViewModel = PhotosViewModel(networkManager: networkManager, authManager: authManager)
//        return AppDependencyClass(photosViewModel: photosViewModel, networkManager: networkManager, authManager: authManager)
//    }
}
