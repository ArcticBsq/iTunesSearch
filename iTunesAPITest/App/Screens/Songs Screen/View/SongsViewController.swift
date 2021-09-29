//
//  SongsViewController.swift
//  iTunesAPITest
//
//  Created by Илья Москалев on 27.09.2021.
//

import UIKit

final class SongsViewController: UIViewController {
// MARK: Outlets
    @IBOutlet weak var albumImageView: UIImageView!

    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var artistNameLabel: UILabel!
    @IBOutlet weak var albumNameLabel: UILabel!
    @IBOutlet weak var tracksCountLabel: UILabel!
    @IBOutlet weak var releaseDateLabel: UILabel!
    @IBOutlet weak var genreLabel: UILabel!

    @IBOutlet weak var songsTableView: UITableView!

    var presenter: SongsPresenterProtocol!

    override func viewDidLoad() {
        super.viewDidLoad()

        songsTableView.register(UITableViewCell.self, forCellReuseIdentifier: "song")
        albumImageView.layer.cornerRadius = 10
        songsTableView.backgroundColor = #colorLiteral(red: 0.8313509822, green: 0.8317731023, blue: 0.7837386727, alpha: 1)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if let url = presenter.getUrlFromDefaults() {
            presenter.saveUrlNilDefaults()
            presenter.getSongs(url: url, term: "")
        }
    }
}

// MARK: Extensions
// Presenter API request response
extension SongsViewController: SongsViewProtocol {
    func success() {
        guard let album = presenter.album else { return }
        if let url = URL(string: album.artworkUrl100) {
            self.albumImageView.cacheImage(url: url)
        }
        artistNameLabel.text = "Artist: \(album.artistName)"
        albumNameLabel.text = "Album: \(album.collectionName)"
        tracksCountLabel.text = "Tracks: \(album.trackCount)"
        releaseDateLabel.text = "Release: \(album.releaseDate.components(separatedBy: "T")[0])"
        genreLabel.text = "Genre: \(album.primaryGenreName)"

        songsTableView.reloadData()
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

            let searchTerm = presenter.url ?? ""
            let url = self.presenter.resultUrl ?? (Url.song + searchTerm)

            self.presenter.getSongs(url: url, term: searchTerm)
        }))
        present(alertController, animated: true)
    }
}

extension SongsViewController: UITableViewDelegate, UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return presenter.songs?.count ?? 0
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "song", for: indexPath)

        if let songName = presenter.songs?[indexPath.row].trackName {
            cell.textLabel?.text = "\(indexPath.row + 1). \(songName)"
        }
        cell.backgroundColor = #colorLiteral(red: 0.8313509822, green: 0.8317731023, blue: 0.7837386727, alpha: 1)
        cell.isUserInteractionEnabled = false
        return cell
    }
}
