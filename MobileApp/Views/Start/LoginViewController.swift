//
//  StartViewController.swift
//  MobileApp
//
//  Created by Evgenii Mikhailov on 19.04.2023.
//

import Foundation
import UIKit
import Combine
import WebKit


class LoginViewController: UIViewController, WKNavigationDelegate {
    
    private var authManager: AuthManagerProtocol
    private var cancellables = Set<AnyCancellable>()
    
    private let enterButton: UIButton = {
        let button = UIButton()
        button.setTitle("Enter VK", for: .normal)
        button.setTitleColor(UIColor.systemBackground, for: .normal)
        button.backgroundColor = .label
        button.layer.cornerRadius = 15
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Mobile Up \nGallery"
        label.font = .boldSystemFont(ofSize: 44)
        label.textColor = .label
        label.numberOfLines = 0
        return label
    }()
    
    init(authManager: AuthManager) {
        self.authManager = authManager
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        view.addSubview(enterButton)
        view.addSubview(titleLabel)
        enterButton.addTarget(self, action: #selector(didPressed), for: .touchUpInside)
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: view.topAnchor, constant: 170),
            titleLabel.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 24),
            titleLabel.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -124),
           titleLabel.bottomAnchor.constraint(equalTo: enterButton.topAnchor, constant: -442),
            enterButton.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            enterButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16),
            enterButton.heightAnchor.constraint(equalToConstant: 52),
            enterButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -42)
        ])
    }
    
    @objc func didPressed() {
        let authWebView = WebViewUIKit()
        authWebView.modalPresentationStyle = .fullScreen
        present(authWebView, animated: true)
        
        authWebView.tokenSubject
            .sink { [weak self] token in
                print("Getting Token")
                self?.authManager.token = token
                self?.authManager.saveAccessToken(token: token)
                
                DispatchQueue.main.async {
                    let photosVM = PhotosViewModel(networkManager: AppDependency.shared.networkManager)
                    let photosVC = PhotosViewController(viewModel: photosVM)
                    let navController = UINavigationController(rootViewController: photosVC)
                    
                    if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                       let window = windowScene.windows.first {
                        authWebView.clearCache()
                        authWebView.dismiss(animated: false)
                        window.rootViewController = navController
                        window.makeKeyAndVisible()
                        
                    }
                }
            }
            .store(in: &cancellables)
        
        
        
    }
}
