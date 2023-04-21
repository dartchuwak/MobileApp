//
//  PhotoDetailsViewController.swift
//  MobileApp
//
//  Created by Evgenii Mikhailov on 21.04.2023.
//

import UIKit
import SDWebImage

class PhotoDetailsViewController: UIViewController {
    
    var viewModel: PhotoDetailsViewModel
    
    let photo: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        return imageView
    }()
    
    let collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = 2
        layout.minimumInteritemSpacing = 0
        layout.itemSize = CGSize(width: 54, height: 54)
        
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.backgroundColor = .clear
        
        return collectionView
    }()
    
    init(viewModel: PhotoDetailsViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        view.addSubview(collectionView)
        registerCell()
        NSLayoutConstraint.activate([
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -30),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.heightAnchor.constraint(equalToConstant: 58)
        ])
        
        self.title = viewModel.photo.date.description
        view.addSubview(photo)
        photo.sd_setImage(with: URL(string: viewModel.photo.sizes.last?.url ?? ""))
        let shareButton = UIBarButtonItem(image: UIImage(systemName: "square.and.arrow.up"), style: .plain, target: self, action: #selector(share))
        navigationItem.rightBarButtonItem = shareButton
        
        NSLayoutConstraint.activate([
            photo.widthAnchor.constraint(equalTo: view.widthAnchor),
            photo.heightAnchor.constraint(equalTo: view.widthAnchor),
            photo.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            photo.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
    }
    
    func registerCell() {
        collectionView.register(PhotoCollectionViewCell.self, forCellWithReuseIdentifier: "PhotoCell")
        collectionView.dataSource = self
        collectionView.delegate = self
    }
    
    @objc func share() {
        guard let photoURL = URL(string: viewModel.photo.sizes.last?.url ?? "") else { return }
        let activityItems: [Any] = [photoURL]
        let activityViewController = UIActivityViewController(activityItems: activityItems, applicationActivities: nil)
        self.present(activityViewController, animated: true, completion: nil)
    }
}

extension PhotoDetailsViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.allPhotos.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PhotoCell", for: indexPath) as! PhotoCollectionViewCell
        let photo = viewModel.allPhotos[indexPath.item]
        if let url = URL(string: photo.sizes.last?.url ?? "") {
            cell.imageView.sd_setImage(with: url)
        }
        return cell
    }
}
