//
//  SearchViewPresenter.swift
//  iTunesAPITest
//
//  Created by Илья Москалев on 25.09.2021.
//

import Foundation

protocol SearchViewProtocol: AnyObject {
    func success()
    func failure(error: Error)
}

protocol SearchViewPresenterProtocol: AnyObject {
    init(view: SearchViewProtocol, networkService: NetworkServiceProtocol, dataService: DataServiceProtocol)
    func getAlbums(url: String, searchTerm: String?)
    func saveHistory(url: String)
    var albums: MusicEntities? { get set }
    var searchTerm: String? { get set }
    var history: [String]? { get set }
    func getUrlFromDefaults() -> String?
    func saveUrlNilDefaults()

}

final class SearchPresenter: SearchViewPresenterProtocol {
    var searchTerm: String?

    var albums: MusicEntities?
// MARK: History data work
    var history: [String]? {
        get {
            dataService.getHistoryDefaults()
        } set {
            dataService.saveHistoryDefaults(array: newValue ?? [String]())
        }
    }

    func saveHistory(url: String) {
        history?.append(url)
    }

    weak var view: SearchViewProtocol?
    let networkService: NetworkServiceProtocol
    let dataService: DataServiceProtocol

    required init(view: SearchViewProtocol, networkService: NetworkServiceProtocol, dataService: DataServiceProtocol) {
        self.view = view
        self.networkService = networkService
        self.dataService = dataService
    }

// MARK: Network
    func getAlbums(url: String, searchTerm: String?) {
        guard let term = searchTerm else { return }

        networkService.fetchData(url: url, searchTerm: term) { [weak self] result, error, historyUrl in
            guard let self = self else { return }
            self.saveHistory(url: historyUrl)
            DispatchQueue.main.async {
                if let result = result {
                    if !result.isEmpty {
                        self.albums = result.sorted {$0.collectionName < $1.collectionName}
                        self.view?.success()
                    }
                } else {
                    guard let error = error else { return }
                    self.view?.failure(error: error)
                }
            }
        }
        self.searchTerm = searchTerm
    }
// MARK: Datawork
    func getUrlFromDefaults() -> String? {
        let result = dataService.getHistoryStatus(key: UserDefaultsKeys.albumsHistory)
        return result
    }

    func saveUrlNilDefaults() {
        dataService.saveHistoryStatus(url: nil, key: UserDefaultsKeys.albumsHistory)
    }
}
