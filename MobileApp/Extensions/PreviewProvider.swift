//
//  PreviewProvider.swift
//  MobileApp
//
//  Created by Evgenii Mikhailov on 21.04.2023.
//

import Foundation
import SwiftUI

extension PreviewProvider {
    static var dev: DeveloperPreview {
        return DeveloperPreview.instance
    }
}

class DeveloperPreview {
    static let instance = DeveloperPreview()
    private init() { }
    
    let homeVM = PhotosViewModel(networkManager: NetworkManager())
    
    let photo = Photo(id: 1,
                      sizes: [Size(url:"https://sun9-16.userapi.com/impg/RQH-Tl7aCPGpGgpKEl4UE4NxwSVgvzdxFL4nTA/SmZtfONekUk.jpg?size=538x807&quality=96&sign=cd4824d5e83a7d85252154c777314dd2&c_uniq_tag=4JddEt45L4I8vlCNkyphhop0xK1nPPVrzeeQoJ5ryTA&type=album")], date: 16111990)
}
