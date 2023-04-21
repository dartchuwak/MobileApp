//
//  FriendsViewModel.swift
//  WishlistApp
//
//  Created by Evgenii Mikhailov on 05.04.2023.
//

import Foundation
import Combine


class PhotosViewModel: ObservableObject {

    let networkManager: NetworkManagerProtocol
    var token: String? = nil
    private var cancellables = Set<AnyCancellable>()
    @Published var photos: [Photo] = []
    @Published var error: Error?
    @Published var isTokenValid: Bool?
    var onInvalidToken: (() -> Void)?
    
    init(networkManager: NetworkManagerProtocol) {
        self.networkManager = networkManager
    }
    

    
    func getImages(token: String) {
        networkManager.getPhotos(token: token)
            .sink(receiveCompletion: { completion in
                switch completion {
                case .finished:
                    break
                case .failure(let error):
                    if let networkError = error as? NetworkError {
                               print("Error: \(networkError.localizedDescription)")
                           } else {
                               print("Error: \(error.localizedDescription)")
                           }
                    self.error = error
                }
            }, receiveValue: { [weak self] response in
                self?.photos = response.response.items
            })
            .store(in: &cancellables)

    }
    
    func testTokenValidity() async {
        do {
            let isValid = try await networkManager.checkTokenValidity(accessToken: token!)
            if isValid {
                print("Токен действителен")
                self.isTokenValid = true
            } else {
                print("Токен недействителен или просрочен")
                self.isTokenValid = false
            }
        } catch {
            print("Error: \(error)")
        }
    }
    
    
}
