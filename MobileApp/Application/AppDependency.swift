//
//  App.swift
//  MobileApp
//
//  Created by Evgenii Mikhailov on 20.04.2023.
//

import Foundation

class AppDependencyClass {
    let photosViewModel: PhotosViewModel
    let networkManager: NetworkManagerProtocol
    let authManager: AuthManagerProtocol
    
    init(photosViewModel: PhotosViewModel, networkManager: NetworkManagerProtocol, authManager: AuthManagerProtocol) {
        self.photosViewModel = photosViewModel
        self.networkManager = networkManager
        self.authManager = authManager
        
    }
    
    static func configure() -> AppDependencyClass {
        let networkManager = NetworkManager()
        let authManager = AuthManager.shared
        let photosViewModel = PhotosViewModel(networkManager: networkManager, authManager: authManager)
        return AppDependencyClass(photosViewModel: photosViewModel, networkManager: networkManager, authManager: authManager)
    }
}
