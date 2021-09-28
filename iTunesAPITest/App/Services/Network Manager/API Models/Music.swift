//
//  ApiModels.swift
//  iTunesAPITest
//
//  Created by Илья Москалев on 25.09.2021.
//

import Foundation

struct MusicResults: Decodable {
    let results: MusicEntities
}

struct MusicEntity: Codable {
    let artistName: String
    let collectionName: String
    let artworkUrl100: String
    let trackCount: Int
    let releaseDate: String
    let primaryGenreName: String
    let collectionId: Int
    let trackName: String?
}

typealias MusicEntities = [MusicEntity]
