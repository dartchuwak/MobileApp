//
//  PhotoDetailsViewModel.swift
//  MobileApp
//
//  Created by Evgenii Mikhailov on 21.04.2023.
//

import Foundation
import Combine


final class PhotoDetailsViewModel {
    
    var photo: Photo
    var allPhotos: [Photo]
    
    init(photo: Photo, allPhotos: [Photo]) {
        self.photo = photo
        self.allPhotos = allPhotos
    }
    
    
}
