//
//  LaunchScreen.swift
//  MobileApp
//
//  Created by Evgenii Mikhailov on 21.04.2023.
//

import Foundation
import UIKit

class LaunchScreenViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        guard let launchScreenView = UIStoryboard(name: "LaunchScreen", bundle: nil).instantiateInitialViewController()?.view else { return}
        launchScreenView.frame = view.bounds
        view.addSubview(launchScreenView)
        view.backgroundColor = .systemBackground
    }
}
