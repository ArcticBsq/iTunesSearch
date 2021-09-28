//
//  DataManager.swift
//  iTunesAPITest
//
//  Created by Илья Москалев on 25.09.2021.
//

import Foundation

enum UserDefaultsKeys {
    static let history: String = "History" // work with array of all history tabs
    static let songsHistory: String = "SongsUrl" // history url of songs page
    static let albumsHistory: String = "AlbumsUrl" // history url of albums page
}

protocol DataServiceProtocol {
    func saveHistoryDefaults(array: [String])
    func getHistoryDefaults() -> [String]?

    func saveHistoryStatus(url: String?, key: String)
    func getHistoryStatus(key: String) -> String?
}

final class DataService: DataServiceProtocol {
    private let defaults = UserDefaults.standard

// Save history tabs as array of String to UserDefaults
    func saveHistoryDefaults(array: [String]) {
        defaults.set(array, forKey: "History")
    }
// Get history tabs as array of String to UserDefaults
    func getHistoryDefaults() -> [String]? {
        let array = defaults.stringArray(forKey: "History") ?? [String]()
        return array
    }
// Saves url of history page
    func saveHistoryStatus(url: String?, key: String) {
        defaults.set(url, forKey: key)
    }
// Loads url of history page
    func getHistoryStatus(key: String) -> String? {
        let result = defaults.string(forKey: key)
        return result
    }

}
