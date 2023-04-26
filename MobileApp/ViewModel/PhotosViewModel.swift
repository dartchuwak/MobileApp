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
    
    private var networkManager: NetworkManagerProtocol
    private var authManager: AuthManagerProtocol
    private var cancellables = Set<AnyCancellable>()
    @Published var photos: [Photo] = []
    @Published var error: Error?
    
    init(networkManager: NetworkManagerProtocol, authManager: AuthManagerProtocol) {
        self.networkManager = networkManager
        self.authManager = authManager
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


