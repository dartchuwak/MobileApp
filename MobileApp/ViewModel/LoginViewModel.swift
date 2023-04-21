//
//  LoginViewModel.swift
//  WishlistApp
//
//  Created by Evgenii Mikhailov on 05.04.2023.
//

import UIKit
import SwiftUI

protocol LoginViewModelProtocol {
    var token: String? { get set }
    func saveAccessToken(token: String)
    func loadAccessToken() -> String?
    var isTokenValid: Bool { get }
}

class LoginViewModel: LoginViewModelProtocol {
    
    var networkManager = NetworkManager()
    var token: String? = ""
    var isTokenValid: Bool = false
    
    func saveAccessToken(token: String) {
        UserDefaults.standard.set(token, forKey: "access_token")
    }

    func loadAccessToken() -> String? {
        return UserDefaults.standard.string(forKey: "access_token")
    }
    
    func testTokenValidity() async -> Bool {
        do {
            let isValid = try await networkManager.checkTokenValidity(accessToken: token!)
            if isValid {
                print("Токен действителен")
                self.isTokenValid = true
                return true
            } else {
                print("Токен недействителен или просрочен")
                self.isTokenValid = false
                return false
            }
        } catch {
            print("Error: \(error)")
            return false
        }
    }
    
}
