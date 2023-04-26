//
//  LoginViewModel.swift
//  WishlistApp
//
//  Created by Evgenii Mikhailov on 05.04.2023.
//

import UIKit
import KeychainSwift

protocol AuthManagerProtocol {
    var token: String { get set }
    func testTokenValidity() async -> Bool
    func saveAccessToken(token: String)
    func loadAccessToken() -> Bool
    func deleteAccessToken()
}

final class AuthManager: AuthManagerProtocol {
        
    private let keychain = KeychainSwift()
    private let networkManager: NetworkManagerProtocol
    
    init(networkManager: NetworkManagerProtocol) {
        self.networkManager = networkManager
    }
    
    
    var token: String = ""
    
    func testTokenValidity() async -> Bool {
        do {
            let isValid = try await networkManager.checkTokenValidity(accessToken: token)
            if isValid {
                print("Токен действителен")
                return true
            } else {
                print("Токен недействителен или просрочен")
                return false
            }
        } catch {
            print("Error: \(error)")
            return false
        }
    }
    
    func saveAccessToken(token: String) {
        keychain.set(token, forKey: "com.MobileApp.oauth.token")
    }
    
    func loadAccessToken() -> Bool {
        if let accessToken = keychain.get("com.MobileApp.oauth.token") {
            print("Токен загружен")
            self.token = accessToken
            return true
        } else {
            print("Токен не найден")
            return false
        }
    }
    
    func deleteAccessToken() {
        token = ""
        keychain.delete("com.MobileApp.oauth.token")
        print("Токен удален из Keychain")
        
    }
    
}
