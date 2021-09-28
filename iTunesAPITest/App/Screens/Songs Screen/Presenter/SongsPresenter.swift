//
//  SongsPresenter.swift
//  iTunesAPITest
//
//  Created by Илья Москалев on 27.09.2021.
//

import Foundation

protocol SongsViewProtocol: AnyObject {
    func success()
    func failure(error: Error)
}

protocol SongsPresenterProtocol: AnyObject {
    init(view: SongsViewProtocol, networkService: NetworkServiceProtocol,
         url: String?, dataService: DataServiceProtocol, fullUrl: String?)

    func getSongs(url: String, term: String)
    var songs: MusicEntities? { get set }
    var url: String? { get set }
    var album: MusicEntity? { get set }
    var fullUrl: String? { get set }

    func getUrlFromDefaults() -> String?
    func saveUrlNilDefaults()

    var albumSong: MusicEntity? { get set }
}

final class SongsPresenter: SongsPresenterProtocol {
    var url: String?

    var fullUrl: String?

    var album: MusicEntity?

    var albumSong: MusicEntity?

    weak var view: SongsViewProtocol?

    var songs: MusicEntities?

    var history: [String]? {
        get {
            dataService.getHistoryDefaults()
        } set {
            dataService.saveHistoryDefaults(array: newValue ?? [String]())
        }
    }

    let networkService: NetworkServiceProtocol

    var dataService: DataServiceProtocol

    init(view: SongsViewProtocol, networkService: NetworkServiceProtocol,
         url: String?, dataService: DataServiceProtocol, fullUrl: String?) {

        self.view = view
        self.networkService = networkService
        self.dataService = dataService
        self.url = url
        self.fullUrl = fullUrl
        if let valueUrl = self.url {
            self.getSongs(url: Url.song, term: valueUrl)
        }

    }
// MARK: Network
    func getSongs(url: String, term: String) {
        networkService.fetchData(url: url, searchTerm: term) { [weak self] result, error, historyUrl in
            guard let self = self else { return }
            self.saveHistory(url: historyUrl)
            DispatchQueue.main.async {
                if let result = result {
                    if !result.isEmpty {
                        self.songs = result
                        self.album = self.songs?.removeFirst()
                        self.view?.success()
                    }
                } else {
                    guard let error = error else { return }
                    self.view?.failure(error: error)
                }
            }
        }
    }
// MARK: Datawork
    func saveHistory(url: String) {
        history?.append(url)
    }

    func getUrlFromDefaults() -> String? {
        let result = dataService.getHistoryStatus(key: UserDefaultsKeys.songsHistory)
        return result
    }

    func saveUrlNilDefaults() {
        dataService.saveHistoryStatus(url: nil, key: UserDefaultsKeys.songsHistory)
    }
}
