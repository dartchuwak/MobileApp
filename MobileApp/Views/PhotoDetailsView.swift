//
//  PhotoDetailsView.swift
//  MobileApp
//
//  Created by Evgenii Mikhailov on 20.04.2023.
//

import SwiftUI



struct PhotoDetailsView: View {
    
    @EnvironmentObject var photosVM: PhotosViewModel
    @State private var showShareSheet = false
    @State private var activityItems: [Any] = []
    
    @Environment(\.presentationMode) var presentationMode
    
    @State var photo: Photo
    
    var body: some View {
        GeometryReader { geo in
            VStack {
                VStack {
                    customNavigationBar
                        .background(Color.white)
                    //  .shadow(radius: 2)
                    Rectangle()
                        .fill(Color(.separator))
                        .frame(height: 0.5)
                }
                
                Spacer()
                
                AsyncImage(url: URL(string: photo.sizes.last?.url ?? "")) { image in
                    image.resizable()
                        .aspectRatio(contentMode: .fill)
                } placeholder: {
                    ProgressView()
                }
                .frame(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.width)
                .clipped()
                
                Spacer()
                
                ScrollView(.horizontal) {
                    HStack(spacing: 2) {
                        ForEach(photosVM.photos) { photo in
                            AsyncImage(url: URL(string: photo.sizes.last?.url ?? "")) { image in
                                image.resizable()
                                    .aspectRatio(contentMode: .fill)
                            } placeholder: {
                                ProgressView()
                            }
                            .frame(width: 54, height: 54)
                            .clipped()
                        }
                    }
                }
            }
            .navigationBarHidden(true)
//            .toolbar {
//                shareButton
//            }
//            .navigationTitle(photo.date.description)
//            .navigationBarBackButtonHidden()
//            .navigationBarItems(leading: backButton)
//            .foregroundColor(.black)
        }
        .sheet(isPresented: $showShareSheet) {
            ShareSheet(activityItems: activityItems)
           }
    }
        
        private var shareButton: some View {
            Button(action: {
                share()
            }) {
                Image(systemName: "square.and.arrow.up")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 20, height: 20)
            }
            
        }
        
        private var backButton: some View {
            Button(action: {
                presentationMode.wrappedValue.dismiss()
            }) {
                HStack {
                    Image(systemName: "chevron.backward")
                    
                }
            }
        }
        
    private func share() {
        if let url = URL(string: photo.sizes.last?.url ?? ""),
           let image = loadImage(from: url) {
            activityItems = [image]
            showShareSheet = true
        }
    }
        
        private var customNavigationBar: some View {
            HStack {
                backButton
                    .padding(.leading)
                    .foregroundColor(.black)
                Spacer()
                shareButton
                    .padding(.trailing)
                    .foregroundColor(.black)
            }
            .frame(height: 44)
            
        }
    
    private func loadImage(from url: URL) -> UIImage? {
        guard let data = try? Data(contentsOf: url) else { return nil }
        return UIImage(data: data)
    }
}

struct PhotoDetailsView_Previews: PreviewProvider {
    
    //static var vm: PhotosViewModel = PhotosViewModel(networkManager: NetworkManager())
    static var previews: some View {
        PhotoDetailsView(photo: dev.photo)
            .environmentObject(appDependency.photosViewModel)
    }
}

struct ShareSheet: UIViewControllerRepresentable {
    let activityItems: [Any]
    
    func makeUIViewController(context: Context) -> UIActivityViewController {
        let controller = UIActivityViewController(activityItems: activityItems, applicationActivities: nil)
        return controller
    }
    
    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {
    }
}
