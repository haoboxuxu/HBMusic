//
//  APICaller-Search.swift
//  HBMusic
//
//  Created by 徐浩博 on 2021/12/19.
//

import Foundation

extension APICaller {
    public func search(for item: String, completion: @escaping (Result<[SearchResult], Error>) -> Void) {
        let query = item.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        createRequest(with: URL(string: Constants.baseAPIURL+"/search?type=track,artist,album,playlist&q=\(query)"), type: .GET) { request in
            URLSession.shared.dataTask(with: request) { data, _, error in
                guard let data = data, error == nil else {
                    completion(.failure(APIError.FaliedToGetData))
                    return
                }
                
                do {
                    let results = try JSONDecoder().decode(SearchResultsResponce.self, from: data)
                    
                    var searchResults: [SearchResult] = []
                    
                    searchResults.append(contentsOf: results.albums.items.compactMap({
                        SearchResult.album(model: $0)
                    }))
                    searchResults.append(contentsOf: results.artists.items.compactMap({
                        SearchResult.artist(model: $0)
                    }))
                    searchResults.append(contentsOf: results.playlists.items.compactMap({
                        SearchResult.playlist(model: $0)
                    }))
                    searchResults.append(contentsOf: results.tracks.items.compactMap({
                        SearchResult.track(model: $0)
                    }))
                    
                    completion(.success(searchResults))
                } catch {
                    print(error.localizedDescription)
                    completion(.failure(error))
                }
            }.resume()
        }
    }
}
