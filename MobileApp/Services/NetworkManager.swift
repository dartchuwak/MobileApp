//
//  NetworkManager.swift
//  WishlistApp
//
//  Created by Evgenii Mikhailov on 05.04.2023.
//

import Foundation
import Combine

protocol NetworkManagerProtocol {
    func getPhotos(token: String)  -> AnyPublisher<PhotosResponse, Error>
    func checkTokenValidity(accessToken: String) async throws -> Bool
}

final class NetworkManager: NetworkManagerProtocol {

    func getPhotos(token: String)  -> AnyPublisher<PhotosResponse, Error> {
        var url = URLComponents(string: "https://api.vk.com/method/photos.get")
        url?.queryItems = [
            URLQueryItem(name: "access_token", value: token),
            URLQueryItem(name: "owner_id", value: "-128666765"),
            URLQueryItem(name: "album_id", value: "266310117"),
            URLQueryItem(name: "v", value: "5.131"),
            URLQueryItem(name: "count", value: "200")
        ]
        
        return URLSession.shared.dataTaskPublisher(for: (url?.url)!)
            .tryMap { data, response -> Data in
                guard let httpResponse = response as? HTTPURLResponse else {
                    throw NetworkError.unknown
                }
                switch httpResponse.statusCode {
                case 200:
                    return data
                case 400:
                    throw NetworkError.badRequest
                case 401:
                    throw NetworkError.unauthorized
                case 404:
                    throw NetworkError.notFound
                case 500:
                    throw NetworkError.internalServerError
                default:
                    throw NetworkError.unknown
                }
            }
            .decode(type: PhotosResponse.self, decoder: JSONDecoder())
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
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
