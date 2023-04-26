//
//  FriendsModel.swift
//  WishlistApp
//
//  Created by Evgenii Mikhailov on 05.04.2023.
//

import Foundation


struct PhotosResponse: Decodable,Hashable{
    let response: Response
}

struct Response: Decodable,Hashable {
    let items: [Photo]
}

struct Photo: Decodable,Hashable,Identifiable {
    let id: Int
    let sizes: [Size]
    let date: Int
}

struct Size: Decodable, Hashable {
    let url: String
}


