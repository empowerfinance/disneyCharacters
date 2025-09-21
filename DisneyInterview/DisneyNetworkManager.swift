//
//  DisneyNetworkManager.swift
//  ToDoList
//
//  Created by Dotan Tamir on 17/9/2025.
//

import Foundation
import Combine

class DisneyNetworkManager {
    
    // MARK: - Properties
    private let baseURL = "https://api.disneyapi.dev"
    private let session = URLSession.shared
    
    // MARK: - Error Types
    enum DisneyNetworkError: Error {
        case invalidURL
        case noData
        case decodingError
        case networkError(Error)
        
        var localizedDescription: String {
            switch self {
            case .invalidURL:
                return "Invalid URL"
            case .noData:
                return "No data received"
            case .decodingError:
                return "Failed to decode response"
            case .networkError(let error):
                return "Network error: \(error.localizedDescription)"
            }
        }
    }
    
    // MARK: - Public Methods

    /// Fetch all characters with pagination
    func fetchCharacters(page: Int = 1, pageSize: Int = 50) -> AnyPublisher<DisneyCharacterResponse, DisneyNetworkError> {
        let urlString = "\(baseURL)/character?page=\(page)&pageSize=\(pageSize)"

        guard let url = URL(string: urlString) else {
            return Fail(error: DisneyNetworkError.invalidURL)
                .eraseToAnyPublisher()
        }

        return performRequest(url: url, responseType: DisneyCharacterResponse.self)
    }
    
    /// Fetch a specific character by ID
    func fetchCharacter(id: Int) -> AnyPublisher<DisneyCharacterDetailResponse, DisneyNetworkError> {
        let urlString = "\(baseURL)/character/\(id)"

        guard let url = URL(string: urlString) else {
            return Fail(error: DisneyNetworkError.invalidURL)
                .eraseToAnyPublisher()
        }

        return performRequest(url: url, responseType: DisneyCharacterDetailResponse.self)
    }
    
    /// Search characters by name
    func searchCharacters(name: String) -> AnyPublisher<DisneyCharacterResponse, DisneyNetworkError> {
        let encodedName = name.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        let urlString = "\(baseURL)/character?name=\(encodedName)"

        guard let url = URL(string: urlString) else {
            return Fail(error: DisneyNetworkError.invalidURL)
                .eraseToAnyPublisher()
        }

        return performRequest(url: url, responseType: DisneyCharacterResponse.self)
    }
    
    // MARK: - Private Methods

    private func performRequest<T: Codable>(url: URL, responseType: T.Type) -> AnyPublisher<T, DisneyNetworkError> {
        return session.dataTaskPublisher(for: url)
            .map(\.data)
            .decode(type: responseType, decoder: JSONDecoder())
            .mapError { error in
                if error is DecodingError {
                    return DisneyNetworkError.decodingError
                } else {
                    return DisneyNetworkError.networkError(error)
                }
            }
            .eraseToAnyPublisher()
    }
}
