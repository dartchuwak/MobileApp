//
//  FriendsViewModel.swift
//  WishlistApp
//
//  Created by Evgenii Mikhailov on 05.04.2023.
//

import Foundation
import Combine
import UIKit
import SDWebImage

class PhotosViewModel: ObservableObject {

    let networkManager: NetworkManagerProtocol
    let authManager = AuthManager.shared
    private var cancellables = Set<AnyCancellable>()
    @Published var photos: [Photo] = []
    @Published var error: Error?
    //@Published var allPhotos: [Photo] = []
    
    init(networkManager: NetworkManagerProtocol) {
        self.networkManager = networkManager
    }
    
    func getImagesURL() {
        let token = authManager.token
        print(token)
        Task {
            let result = await networkManager.getImagesURL(token: token)
            switch result {
            case .success(let photos):
                    self.photos = photos
            case .failure(let error):
                self.error = error
            }
        }
    }
    
    func unixToDate(unixDate: Int) -> Date {
        let date = try! Date(timeIntervalSince1970: TimeInterval(from: unixDate as! Decoder))
        return date
        
    }
    
    
    
    
}


