//
//  HistoryvIEWPresenter.swift
//  iTunesAPITest
//
//  Created by Илья Москалев on 25.09.2021.
//

import Foundation

protocol HistoryViewProtocol: AnyObject {
    func updateView()
    func historyUrlUpdateSuccessAlbums()
    func historyUrlUpdateSuccessSongs()
}

protocol HistoryViewPresenterProtocol: AnyObject {
    init(view: HistoryViewProtocol, dataService: DataServiceProtocol)
    
    func loadHistory()
    var historyObjects: [String]? { get set }
    var historyUrl: String? { get set }
    
    func loadUrlToDefaults(url: String, key: String)
}

final class HistoryPresenter: HistoryViewPresenterProtocol {
    weak var view: HistoryViewProtocol?
    
    let dataService: DataServiceProtocol!
    
    var historyObjects: [String]?
    
    var historyUrl: String?
    
    required init(view: HistoryViewProtocol, dataService: DataServiceProtocol) {
        self.view = view
        self.dataService = dataService
    }
    
    func loadHistory() {
        historyObjects = dataService.getHistoryDefaults() ?? [String]()
        view?.updateView()
    }
    
    func loadUrlToDefaults(url: String, key: String) {
        dataService.saveHistoryStatus(url: url, key: key)
        self.historyUrl = url
        if key == "AlbumsUrl" {
            self.view?.historyUrlUpdateSuccessAlbums()
        } else {
            self.view?.historyUrlUpdateSuccessSongs()
        }
    }
}
