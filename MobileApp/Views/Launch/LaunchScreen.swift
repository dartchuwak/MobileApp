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

        // Загрузите Launch Screen из вашего файла storyboard или создайте его вручную
        let launchScreenView = UIStoryboard(name: "LaunchScreen", bundle: nil).instantiateInitialViewController()?.view
        launchScreenView?.frame = view.bounds
        view.addSubview(launchScreenView!)
    }
}
