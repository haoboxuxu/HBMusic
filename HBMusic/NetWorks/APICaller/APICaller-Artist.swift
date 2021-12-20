//
//  APICaller-Artist.swift
//  HBMusic
//
//  Created by 徐浩博 on 2021/12/19.
//

import Foundation

extension APICaller {
    public func getArtist(id: String, completion: @escaping (Result<String, Error>) -> Void) {
        createRequest(with: URL(string: Constants.baseAPIURL+"/artists/\(id)"), type: .GET) { baseRequest in
            URLSession.shared.dataTask(with: baseRequest) { data, _, error in
                guard let data = data, error == nil else {
                    completion(.failure(APIError.FaliedToGetFeaturedPlaylists))
                    return
                }

                do {
                    //let results = try JSONDecoder().decode(SeveralArtistsResponce.self, from: data)
                    print(try JSONSerialization.jsonObject(with: data, options: .allowFragments))
                    //completion(.success(results))
                } catch {
                    print(error.localizedDescription)
                    completion(.failure(error))
                }
            }.resume()
        }
    }
    
    public func getSeveralArtists(ids: String, completion: @escaping (Result<SeveralArtistsResponce, Error>) -> Void) {
        createRequest(with: URL(string: Constants.baseAPIURL+"/artists?ids=\(ids)"), type: .GET) { request in
            URLSession.shared.dataTask(with: request) { data, _, error in
                guard let data = data, error == nil else {
                    completion(.failure(APIError.FaliedToGetFeaturedPlaylists))
                    return
                }

                do {
                    let results = try JSONDecoder().decode(SeveralArtistsResponce.self, from: data)
                    completion(.success(results))
                } catch {
                    print(error.localizedDescription)
                    completion(.failure(error))
                }
            }.resume()
        }
    }
}
