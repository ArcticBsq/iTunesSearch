//
//  SearchViewController.swift
//  iTunesAPITest
//
//  Created by Илья Москалев on 25.09.2021.
//

import UIKit

final class SearchViewController: UIViewController {

    var presenter: SearchViewPresenterProtocol!

// MARK: CollectionView
    @IBOutlet weak var collectionView: UICollectionView!
    private func scrollToTop() {
        DispatchQueue.main.async {
            if self.collectionView.numberOfItems(inSection: 0) > 0 {
                self.collectionView.scrollToItem(at: IndexPath(row: 0, section: 0), at: .top, animated: true)
            }
        }
    }

// MARK: Search Controller
    private let searchController = UISearchController(searchResultsController: nil)

    private func setupSearchController() {
        searchController.searchBar.delegate = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Type artist and search albums"
        navigationItem.searchController = searchController
        definesPresentationContext = true
        searchController.hidesNavigationBarDuringPresentation = false
    }

    private var timer: Timer?

    override func viewDidLoad() {
        super.viewDidLoad()

        collectionView.backgroundColor = #colorLiteral(red: 0.8313509822, green: 0.8317731023, blue: 0.7837386727, alpha: 1)

        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        setupSearchController()
        collectionView.register(UINib(nibName: "CustomCollectionCell", bundle: nil), forCellWithReuseIdentifier: "cell")
    }

// MARK: Loading data from History
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if let url = presenter.getUrlFromDefaults() {
            searchController.searchBar.text = nil
            presenter.saveUrlNilDefaults()
            presenter.getAlbums(url: url, searchTerm: "")
        }
    }
}

// MARK: Extensions
// Presenter response
extension SearchViewController: SearchViewProtocol {
    func emptySuccess() {
        let alertController = UIAlertController(title: "Oops",
                                                message: "Requst sent zero albums, try to make request more accurately.",
                                                preferredStyle: .alert)

        alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: { [weak self] _ in
            guard let self = self else { return }

            let badRequestTerm = self.searchController.searchBar.text ?? ""
            self.searchController.searchBar.text = nil
            self.searchController.searchBar.placeholder = "Previous - \(badRequestTerm)"
        }))
        present(alertController, animated: true)
    }

    func success() {
        self.scrollToTop()
        self.collectionView.reloadData()
    }
// MARK: Network error handling
    func failure(error: Error) {
        let alertController = UIAlertController(title: "Error",
                                                message: "Error - \(error.localizedDescription)",
                                                preferredStyle: .alert)

        alertController.addAction(UIAlertAction(title: "Close", style: .cancel))
        alertController.addAction(UIAlertAction(title: "Reload", style: .default, handler: { [weak self] _ in
            guard let self = self else { return }
            guard let presenter = self.presenter else { return }

            let searchTerm = presenter.searchTerm ?? ""
            let url = self.presenter.resultUrl ?? (Url.album + searchTerm)

            self.presenter.getAlbums(url: url, searchTerm: "")
        }))
        present(alertController, animated: true)
    }
}
// MARK: Check input string
// is not only made from whitespaces or nil
extension Optional where Wrapped == String {
    func isEmptyOrWhitespace() -> Bool {
        guard let target = self else { return true }

        if target.isEmpty {
            return true
        }
        return (target.trimmingCharacters(in: .whitespaces) == "")
    }
}

// MARK: API Call
// with search term as search bar text
extension SearchViewController: UISearchBarDelegate {
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        let text = searchBar.text
        if !text.isEmptyOrWhitespace() {
            let searchText = text?.replacingOccurrences(of: " ", with: "+")
            self.presenter.getAlbums(url: Url.album, searchTerm: searchText)
        }
    }
}

// MARK: Hide keyboard
// TODO: Broken, needs fix
extension SearchViewController {
    public override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.window?.endEditing(true)
        super.touchesEnded(touches, with: event)
    }
}

// MARK: Collection View
extension SearchViewController: UICollectionViewDataSource,
                                    UICollectionViewDelegate,
                                    UICollectionViewDelegateFlowLayout {

    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {

        let squareSide = (collectionView.frame.width-35) / 2
        return CGSize(width: squareSide, height: squareSide)
    }

    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        insetForSectionAt section: Int) -> UIEdgeInsets {

        return UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10)
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return presenter.albums?.count ?? 0
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath)

        if let cell = cell as? CustomCollectionCell {
            cell.activityIndicator.startAnimating()
            if let albumImageUrlString = presenter.albums?[indexPath.row].artworkUrl100 {
                if let albumImageUrl = URL(string: albumImageUrlString) {
                    cell.imageView.cacheImage(url: albumImageUrl)
                }
            }
            if cell.imageView.image != nil {
                cell.activityIndicator.stopAnimating()
            }
        }
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let album = presenter.albums?[indexPath.row] else { return }
        let url = String(album.collectionId)
        let viewController = ModuleBuilder.createSongsModule(url: url)
        navigationController?.pushViewController(viewController, animated: true)
    }
}
