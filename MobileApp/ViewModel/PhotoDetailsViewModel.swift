//
//  PhotoDetailsViewModel.swift
//  MobileApp
//
//  Created by Evgenii Mikhailov on 21.04.2023.
//

import Foundation
import Combine
import UIKit


final class PhotoDetailsViewModel {
    
    let networkManager: NetworkManagerProtocol
    var photo: Photo
    var allPhotos: [Photo] = []
    
    init(networkManager: NetworkManagerProtocol, photo: Photo, allPhotos: [Photo]) {
        self.networkManager = networkManager
        self.photo = photo
        self.allPhotos = allPhotos
    }
    
    func unixToDate(unixDate: Int) -> String {
        let dateResult = Double(unixDate)
            let date = Date(timeIntervalSince1970: dateResult)
            let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = DateFormatter.Style.long
            let localData = dateFormatter.string(from: date)
            return localData
    }
    
    
}
