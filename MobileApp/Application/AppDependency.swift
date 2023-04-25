//
//  App.swift
//  MobileApp
//
//  Created by Evgenii Mikhailov on 20.04.2023.
//

import Foundation

final class AppDependency {
    static let shared = AppDependency()

    private(set) lazy var photosViewModel: PhotosViewModel = {
        return PhotosViewModel(networkManager: self.networkManager)
    }()
    
    private(set) lazy var networkManager: NetworkManager = {
        return NetworkManager()
    }()
    
    private init() {}
}

