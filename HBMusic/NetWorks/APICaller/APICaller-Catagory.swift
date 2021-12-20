//
//  APICaller-Catagory.swift
//  HBMusic
//
//  Created by 徐浩博 on 2021/12/19.
//

import Foundation

extension APICaller {
    public func getSeveralCatagories(completion: @escaping (Result<[MusicCategory], Error>) -> Void) {
        createRequest(with: URL(string: Constants.baseAPIURL+"/browse/categories?limit=50"), type: .GET) { result in
            URLSession.shared.dataTask(with: result) { data, _, error in
                guard let data = data, error == nil else {
                    completion(.failure(APIError.FaliedToGetData))
                    return
                }

                do {
                    let results = try JSONDecoder().decode(SeveralCategoriesResponce.self, from: data).categories.items
                    completion(.success(results))
                } catch {
                    print(error.localizedDescription)
                    completion(.failure(error))
                }
            }.resume()
        }
    }
    
    public func getCatagoryPlayList(category: MusicCategory, completion: @escaping (Result<[Playlist], Error>) -> Void) {
        createRequest(with: URL(string: Constants.baseAPIURL+"/browse/categories/\(category.id)/playlists?limit=50"), type: .GET) { request in
            URLSession.shared.dataTask(with: request) { data, _, error in
                guard let data = data, error == nil else {
                    completion(.failure(APIError.FaliedToGetData))
                    return
                }

                do {
                    let results = try JSONDecoder().decode(CatagoryPlaylistsResponce.self, from: data).playlists.items
                    completion(.success(results))
                } catch {
                    print(error.localizedDescription)
                    completion(.failure(error))
                }
            }.resume()
        }
    }
}
