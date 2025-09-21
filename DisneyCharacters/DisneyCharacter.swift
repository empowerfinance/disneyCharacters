//
//  DisneyCharacter.swift
//  ToDoList
//
//  Created by Dotan Tamir on 17/9/2025.
//

import Foundation

// MARK: - API Response Models
struct DisneyCharacterResponse: Codable {
    let info: DisneyResponseInfo
    let data: [DisneyCharacter]
}

struct DisneyCharacterDetailResponse: Codable {
    let info: DisneyResponseInfo
    let data: DisneyCharacter
}

struct DisneyResponseInfo: Codable {
    let totalPages: Int?
    let count: Int
    let previousPage: String?
    let nextPage: String?
}

// MARK: - Character Model
struct DisneyCharacter: Codable {
    let id: Int
    let name: String
    let imageUrl: String?
    let sourceUrl: String?
    let films: [String]
    let shortFilms: [String]
    let tvShows: [String]
    let videoGames: [String]
    let parkAttractions: [String]
    let allies: [String]
    let enemies: [String]
    let url: String
    let createdAt: String?
    let updatedAt: String?



    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case name
        case imageUrl
        case sourceUrl
        case films
        case shortFilms
        case tvShows
        case videoGames
        case parkAttractions
        case allies
        case enemies
        case url
        case createdAt
        case updatedAt
    }
}

// MARK: - Character Extensions
extension DisneyCharacter {
    var hasImage: Bool {
        return imageUrl != nil && !imageUrl!.isEmpty
    }
    
    var totalAppearances: Int {
        return films.count + shortFilms.count + tvShows.count + videoGames.count
    }
    
    var primaryCategory: String {
        if !films.isEmpty {
            return "Films"
        } else if !tvShows.isEmpty {
            return "TV Shows"
        } else if !shortFilms.isEmpty {
            return "Short Films"
        } else if !videoGames.isEmpty {
            return "Video Games"
        } else {
            return "Other"
        }
    }
}
