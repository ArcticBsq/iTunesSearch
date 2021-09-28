//
//  HistoryViewController.swift
//  iTunesAPITest
//
//  Created by Илья Москалев on 25.09.2021.
//

import UIKit

class HistoryViewController: UIViewController {

    @IBOutlet weak var historyTableView: UITableView!
    var presenter: HistoryViewPresenterProtocol!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.view.backgroundColor = #colorLiteral(red: 0.8313509822, green: 0.8317731023, blue: 0.7837386727, alpha: 1)
        
        historyTableView.register(UITableViewCell.self, forCellReuseIdentifier: "history")
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        presenter.loadHistory()
    }
    
}

extension HistoryViewController: HistoryViewProtocol {
    func historyUrlUpdateSuccessSongs() {
        guard let url = presenter.historyUrl else { return }
        let vc = ModuleBuilder.createSongsModule(url: url)
        navigationController?.pushViewController(vc, animated: true)
    }
    
    func historyUrlUpdateSuccessAlbums() {
        tabBarController?.selectedIndex = 0
    }
    
    func updateView() {
        historyTableView.reloadData()
    }
}

extension HistoryViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return presenter.historyObjects?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = historyTableView.dequeueReusableCell(withIdentifier: "history", for: indexPath)
        
        guard let historyPage = presenter.historyObjects?[indexPath.row] else { return cell }
        
        cell.textLabel?.text = historyPage
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let historyPage = presenter.historyObjects?[indexPath.row] else { return }
        
        let key = historyPage.contains("lookup") ? UserDefaultsKeys.songsHistory : UserDefaultsKeys.albumsHistory
        
        presenter.loadUrlToDefaults(url: historyPage, key: key)
    }
}
