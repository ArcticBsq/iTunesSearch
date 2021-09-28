//
//  ModuleBuilder.swift
//  iTunesAPITest
//
//  Created by Илья Москалев on 25.09.2021.
//

import UIKit

protocol Builder {
    static func createSearchModule() -> UIViewController
    static func createHistoryModule() -> UIViewController
    static func createSongsModule(url: String) -> UIViewController
}

final class ModuleBuilder: Builder {
    static func createSearchModule() -> UIViewController {
        let view = SearchViewController()
        let networkService = NetworkService()
        let dataService = DataService()
        let presenter = SearchPresenter(view: view, networkService: networkService, dataService: dataService)
        view.presenter = presenter
        return view
    }

    static func createHistoryModule() -> UIViewController {
        let view = HistoryViewController()
        let dataService = DataService()
        let presenter = HistoryPresenter(view: view, dataService: dataService)
        view.presenter = presenter
        return view
    }

    static func createSongsModule(url: String) -> UIViewController {
        let view = SongsViewController()
        let networkService = NetworkService()
        let dataService = DataService()
        let presenter = SongsPresenter(view: view, networkService: networkService,
                                       url: url, dataService: dataService, fullUrl: nil)
        view.presenter = presenter
        return view
    }
}
