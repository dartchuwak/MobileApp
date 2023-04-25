//
//  NetworkManager.swift
//  WishlistApp
//
//  Created by Evgenii Mikhailov on 05.04.2023.
//

import Foundation
import Combine
import UIKit

protocol NetworkManagerProtocol {
    func checkTokenValidity(accessToken: String) async throws -> Bool
    func loadImage(from url: URL) async -> UIImage?
    func getImagesURL(token: String) async -> Result<[Photo], NetworkError>
}

final class NetworkManager: NetworkManagerProtocol {
    
    func getImagesURL(token: String) async -> Result<[Photo], NetworkError> {
        var url = URLComponents(string: "https://api.vk.com/method/photos.get")
        url?.queryItems = [
            URLQueryItem(name: "access_token", value: token),
            URLQueryItem(name: "owner_id", value: "-128666765"),
            URLQueryItem(name: "album_id", value: "266310117"),
            URLQueryItem(name: "v", value: "5.131"),
            URLQueryItem(name: "count", value: "200")
        ]
        
        do {
            
            let (data, response) = try await URLSession.shared.data(from: (url?.url)!)
            guard let httpResponse = response as? HTTPURLResponse else {
                throw NetworkError.unknown
            }
            
            switch httpResponse.statusCode {
            case 200:
                let apiResponse =  try JSONDecoder().decode(PhotosResponse.self, from: data)
                return .success(apiResponse.response.items)
            case 400:
                return .failure(NetworkError.badRequest)
            case 401:
                return .failure(NetworkError.unauthorized)
            case 404:
                return .failure(NetworkError.notFound)
            case 500:
                return .failure(NetworkError.internalServerError)
            default:
                return .failure(NetworkError.unknown)
            }
        } catch {
            return .failure(NetworkError.badRequest)
        }
    }
    
    func loadImage(from url: URL) async -> UIImage? {
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            return UIImage(data: data)
        } catch {
            print ("Error: \(error.localizedDescription)")
            return nil
        }
    }
    
    func checkTokenValidity(accessToken: String) async throws -> Bool {
        var urlComponents = URLComponents()
        urlComponents.scheme = "https"
        urlComponents.host = "api.vk.com"
        urlComponents.path = "/method/users.get"
        urlComponents.queryItems = [
            URLQueryItem(name: "access_token", value: accessToken),
            URLQueryItem(name: "v", value: "5.131")
        ]
        
        guard let url = urlComponents.url else {
            throw TokenError.invalidURL
        }
        
        let (data, _) = try await URLSession.shared.data(from: url)
        
        if let jsonResponse = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
           let _ = jsonResponse["response"] as? [[String: Any]] {
            return true
        } else if let jsonResponse = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
                  let _ = jsonResponse["error"] as? [String: Any] {
            return false
        } else {
            return false
        }
    }
    
}

enum NetworkError: LocalizedError {
    case badRequest
    case unauthorized
    case notFound
    case internalServerError
    case unknown
    
    var errorDescription: String? {
        switch self {
        case .badRequest:
            return "Bad Request"
        case .unauthorized:
            return "Unauthorized"
        case .notFound:
            return "Not Found"
        case .internalServerError:
            return "Internal Server Error"
        case .unknown:
            return "Unknown Error"
        }
    }
}

enum TokenError: Error {
    case invalidURL
}
