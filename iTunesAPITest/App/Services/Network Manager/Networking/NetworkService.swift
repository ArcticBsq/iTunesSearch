//
//  NetworkManager.swift
//  iTunesAPITest
//
//  Created by Илья Москалев on 25.09.2021.
//

import Foundation

// Urls which we work with to construct our API calls
enum Url {
    static let album: String = "https://itunes.apple.com/search?entity=album&attribute=allArtistTerm&term="
    static let song: String = "https://itunes.apple.com/lookup?entity=song&id="
}

protocol NetworkServiceProtocol {
    func fetchData(url: String, searchTerm: String, completion: @escaping (MusicEntities?, Error?, String) -> Void)
}

final class NetworkService: NetworkServiceProtocol {

    func createDataTask(from request: URLRequest,
                                 completion: @escaping (Data?, Error?) -> Void) -> URLSessionDataTask {

        return URLSession.shared.dataTask(with: request) { (data, _, error) in
            DispatchQueue.main.async {
                completion(data, error)
            }
        }
    }

    func request(typeOfRequest: String, searchTerm: String, completion: @escaping (Data?, Error?) -> Void) {
        guard let url = URL(string: "\(typeOfRequest)+\(searchTerm)+&limit=200") else { return }

        var request = URLRequest(url: url)
        request.httpMethod = "get"

        let task = createDataTask(from: request, completion: completion)
        task.resume()
    }

    func decodeJSON<T: Decodable>(type: T.Type, from: Data?) -> T? {
        let decoder = JSONDecoder()
        guard let data = from else { return nil }

        do {
            let objects = try decoder.decode(type.self, from: data)
            return objects
        } catch let jsonError {
            print("Failed to decode JSON", jsonError)
            return nil
        }
    }

    func fetchData(url: String, searchTerm: String, completion: @escaping (MusicEntities?, Error?, String) -> Void) {
        request(typeOfRequest: url, searchTerm: searchTerm) { data, error in
            let resultUrl = url + searchTerm
            if let error = error {
                completion(nil, error, resultUrl)
            }

            let decode = self.decodeJSON(type: MusicResults.self, from: data)
            completion(decode?.results, nil, resultUrl)
        }
    }
}
