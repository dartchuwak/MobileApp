//
//  StartViewController.swift
//  MobileApp
//
//  Created by Evgenii Mikhailov on 19.04.2023.
//

import Foundation
import UIKit
import Combine


class StartViewController: UIViewController {
    
    var loginViewModel: LoginViewModelProtocol
    var cancellables = Set<AnyCancellable>()
    
    let enterButton: UIButton = {
        let button = UIButton()
        button.setTitle("Enter VK", for: .normal)
        button.backgroundColor = .blue
        button.layer.cornerRadius = 15
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    init(dep: AppDependency) {
        self.loginViewModel = dep.loginViewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .orange
        view.addSubview(enterButton)
        enterButton.addTarget(self, action: #selector(didPressed), for: .touchUpInside)
        
        NSLayoutConstraint.activate([
            enterButton.widthAnchor.constraint(equalToConstant: 150),
            enterButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            enterButton.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
    
    @objc func didPressed() {
        let loginVC = WebViewUIKit()
        loginVC.modalPresentationStyle = .fullScreen
        
        loginVC.tokenSubject
                    .sink { [weak self] token in
                        self?.loginViewModel.token = token
                        self?.loginViewModel.saveAccessToken(token: token)
                        let photosVM = PhotosViewModel(networkManager: NetworkManager())
                        photosVM.token = token
                        self?.dismiss(animated: false)
                        let nav = UINavigationController(rootViewController: PhotosViewController(viewModel: photosVM))
                        nav.modalPresentationStyle = .fullScreen
                        self?.present(nav, animated: true)
                    }
                    .store(in: &cancellables)
        
        present(loginVC, animated: true)

    }
}
