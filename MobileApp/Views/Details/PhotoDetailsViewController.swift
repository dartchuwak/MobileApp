//
//  PhotoDetailsViewController.swift
//  MobileApp
//
//  Created by Evgenii Mikhailov on 21.04.2023.
//

import UIKit
import SDWebImage

final class PhotoDetailsViewController: UIViewController {
    
    var viewModel: PhotoDetailsViewModel
   
    
  private let photo: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        return imageView
    }()
    
    private let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        return scrollView
    }()
    
    private let collectionView: UICollectionView = {
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
        view.backgroundColor = .systemBackground
        navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.label]
        view.addSubview(collectionView)
        registerCell()
        NSLayoutConstraint.activate([
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -30),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.heightAnchor.constraint(equalToConstant: 58)
        ])
        
        self.title = viewModel.unixToDate(unixDate: viewModel.photo.date)
        view.addSubview(photo)
        photo.sd_setImage(with: URL(string: viewModel.photo.sizes.last?.url ?? ""))
        let shareButton = UIBarButtonItem(image: UIImage(systemName: "square.and.arrow.up"), style: .plain, target: self, action: #selector(share))
        navigationItem.rightBarButtonItem = shareButton
        navigationController?.navigationBar.tintColor = .label
        
        NSLayoutConstraint.activate([
            photo.widthAnchor.constraint(equalTo: view.widthAnchor),
            photo.heightAnchor.constraint(equalTo: view.widthAnchor),
            photo.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 24),
            photo.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            photo.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
    }
    
    private func registerCell() {
        collectionView.register(PhotoCollectionViewCell.self, forCellWithReuseIdentifier: "PhotoCell")
        collectionView.dataSource = self
        collectionView.delegate = self
    }
    
    @objc private func share() {
        guard let photoURL = URL(string: viewModel.photo.sizes.last?.url ?? "") else { return }
        Task {
            guard let photo = await viewModel.networkManager.loadImage(from: photoURL) else { return }
            DispatchQueue.main.async {
                let activityItems: [Any] = [photo]
                let activityViewController = UIActivityViewController(activityItems: activityItems, applicationActivities: nil)
                activityViewController.excludedActivityTypes = [
                    .postToFacebook,
                    .postToTwitter,
                    .assignToContact,
                    .print
                ]
                activityViewController.completionWithItemsHandler = { (activityType, completed, returnedItems, error) in
                              if let error = error {
                                  // Обработка ошибки
                                  let alert = UIAlertController(title: NSLocalizedString("alert_save_picture_error_title", comment: ""),
                                                                message: "\(NSLocalizedString("alert_save_picture_error_message", comment: "")) \(error)",
                                                                preferredStyle: .alert)
                                  let okAction = UIAlertAction(title: NSLocalizedString("alert_save_picture_error_confirm", comment: ""), style: .default)
                                  alert.addAction(okAction)
                                  self.present(alert, animated: true)
                              } else {
                                  if completed {
                                      // Операция завершена успешно
                                      let alert = UIAlertController(title: NSLocalizedString("alert_save_picture_title", comment: ""),
                                                                    message: NSLocalizedString("alert_save_picture_message", comment: ""),
                                                                    preferredStyle: .actionSheet)
                                      let okAction = UIAlertAction(title: NSLocalizedString("alert_save_picture_confirm", comment: ""), style: .default)
                                      alert.addAction(okAction)
                                      self.present(alert, animated: true)
                                  } else {
                                      // Операция была отменена пользователем
                                      print("Activity was cancelled")
                                  }
                              }
                          }
                self.present(activityViewController, animated: true, completion: nil)
            }
        }
    }
}

extension PhotoDetailsViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.allPhotos.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PhotoCell", for: indexPath) as! PhotoCollectionViewCell
        let photo = viewModel.allPhotos[indexPath.item]
        cell.imageView.sd_setImage(with: URL(string: photo.sizes.last?.url ?? ""))
        return cell
    }
}
