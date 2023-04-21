//
//  PhotosViewController.swift
//  MobileApp
//
//  Created by Evgenii Mikhailov on 20.04.2023.
//

import Foundation
import UIKit
import SwiftUI
import Combine


class PhotosViewController: UIViewController {
    
    var viewModel: PhotosViewModel
    private var cancellables = Set<AnyCancellable>()
    
    var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        let itemSize = (UIScreen.main.bounds.width - 3 * 1) / 2
        layout.itemSize = CGSize(width: itemSize, height: itemSize)
        layout.minimumLineSpacing = 2
        layout.minimumInteritemSpacing = 2
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        return collectionView
    }()
    
    init(viewModel: PhotosViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
        viewModel.onInvalidToken = { [weak self] in
                DispatchQueue.main.async {
                    let authViewController = WebViewUIKit() // Replace with your actual auth view controller
                    self?.present(authViewController, animated: true, completion: nil)
                    self?.navigationController?.popViewController(animated: false)
                }
            }
    }
    
  
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(collectionView)
        view.backgroundColor = .white
        collectionView.register(ImageCollectionViewCell.self, forCellWithReuseIdentifier: "id")
        collectionView.dataSource = self
        collectionView.delegate = self
        self.title = "MobileApp Gallery"
        
        Task {
            do {
                await viewModel.testTokenValidity()
            }
        }
        
        viewModel.$isTokenValid
            .sink { [weak self] isValid in
                guard let isValid = isValid else { return }
                if isValid {
                    print ("valid")
                    self?.viewModel.getImages(token: self?.viewModel.token ?? "")
                } else {
                    DispatchQueue.main.async {
                        print("Not valid")
                        self?.viewModel.onInvalidToken?()
                    }
                }
            }
            .store(in: &cancellables)
        
        
        viewModel.$photos
            .sink { [weak self] _ in
                self?.collectionView.reloadData()
            }
            .store(in: &cancellables)
        
        viewModel.$error
            .compactMap { $0 }
            .sink { [weak self] error in
                self?.showErrorAlert(error)
            }
            .store(in: &cancellables)
        
        
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: view.topAnchor),
            collectionView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
        
    }
    
    private func showErrorAlert(_ error: Error) {
        let alertController = UIAlertController(title: "Error", message: error.localizedDescription, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alertController, animated: true, completion: nil)
    }
    
}


extension PhotosViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.photos.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "id", for: indexPath) as! ImageCollectionViewCell
        cell.configure(with: viewModel.photos[indexPath.item])
        return cell
    }
}

extension PhotosViewController: UICollectionViewDelegate {
    // Implement any delegate methods if needed
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let photo = viewModel.photos[indexPath.item]
        let vc = UIHostingController(rootView: PhotoDetailsView(photosVM: viewModel, photo: photo))
        vc.title = photo.date.description
        navigationController?.pushViewController(vc, animated: true)
    }
}

