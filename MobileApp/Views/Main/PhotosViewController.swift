//
//  PhotosViewController.swift
//  MobileApp
//
//  Created by Evgenii Mikhailov on 20.04.2023.
//

import Foundation
import UIKit
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
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(collectionView)
        view.backgroundColor = .white
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        collectionView.register(ImageCollectionViewCell.self, forCellWithReuseIdentifier: "id")
        collectionView.dataSource = self
        collectionView.delegate = self
        self.title = "MobileApp Gallery"
        viewModel.getImages(token: viewModel.token!)
        
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
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let photo = viewModel.photos[indexPath.item]
        let vc = PhotoDetailsViewController(viewModel: PhotoDetailsViewModel(photo: photo, allPhotos: viewModel.photos))
        navigationController?.pushViewController(vc, animated: true)
    }
}

