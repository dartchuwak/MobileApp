//
//  PhotoDetailsView.swift
//  MobileApp
//
//  Created by Evgenii Mikhailov on 20.04.2023.
//

import SwiftUI



struct PhotoDetailsView: View {
    
    @ObservedObject var photosVM: PhotosViewModel
    
//    @State var photos: [Photo]
      @State var photo: Photo
    
    var body: some View {
        VStack {
            AsyncImage(url: URL(string: photo.sizes.last?.url ?? "")) { image in
                image.resizable()
                    .aspectRatio(contentMode: .fit)
            } placeholder: {
                ProgressView()
            }
            .frame(width: UIScreen.main.bounds.width)
            
        }
        
        ScrollView(.horizontal) {
            LazyHStack {
                ForEach(photosVM.photos) { photo in
                    AsyncImage(url: URL(string: photo.sizes.last?.url ?? "")) { image in
                        image.resizable()
                            .aspectRatio(contentMode: .fit)
                    } placeholder: {
                        ProgressView()
                    }
                    .frame(height: 100)
                }
            }
        }
        
    }
}

struct PhotoDetailsView_Previews: PreviewProvider {
    static var previews: some View {
        PhotoDetailsView(photosVM: PhotosViewModel(networkManager: NetworkManager()), photo: Photo(id: 1, sizes: [Size(url: "")], date: 2))
    }
}
