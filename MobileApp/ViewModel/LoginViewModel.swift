//
//  LoginViewModel.swift
//  WishlistApp
//
//  Created by Evgenii Mikhailov on 05.04.2023.
//

import UIKit
import SwiftUI
import KeychainSwift

protocol LoginViewModelProtocol {
    var token: String? { get set }
    func saveAccessToken(token: String)
    func loadAccessToken() -> String?
    var isTokenValid: Bool { get }
}

class LoginViewModel: LoginViewModelProtocol {
    
    let keychain = KeychainSwift()
    
    var networkManager = NetworkManager()
    var token: String? = ""
    var isTokenValid: Bool = false
    
    func saveAccessToken(token: String) {
        keychain.set(token, forKey: "com.MobileApp.oauth.token")
    }
    
    func loadAccessToken() -> String? {
        if let accessToken = keychain.get("com.MobileApp.oauth.token") {
            print("Access token: \(accessToken)")
            return accessToken
        } else {
            print("No access token found")
            return nil
        }
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
