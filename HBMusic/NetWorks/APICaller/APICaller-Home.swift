//
//  APICaller-Home.swift
//  HBMusic
//
//  Created by 徐浩博 on 2021/12/19.
//

import Foundation

extension APICaller {
    public func getFeaturedPlaylists(completion: @escaping (Result<FeaturedPlaylistsResponce, Error>) -> Void) {
        createRequest(with: URL(string: Constants.baseAPIURL+"/browse/featured-playlists?limit=50"), type: .GET) { request in
            URLSession.shared.dataTask(with: request) { data, _, error in
                guard let data = data, error == nil else {
                    completion(.failure(APIError.FaliedToGetFeaturedPlaylists))
                    return
                }

                do {
                    let results = try JSONDecoder().decode(FeaturedPlaylistsResponce.self, from: data)
                    completion(.success(results))
                } catch {
                    print(error.localizedDescription)
                    completion(.failure(error))
                }
            }.resume()
        }
    }
    
    public func getRecommendations(genres: Set<String>, completion: @escaping (Result<RecommendationsResponce, Error>) -> Void) {
        let seeds = genres.joined(separator: ",")
        createRequest(with: URL(string: Constants.baseAPIURL+"/recommendations?limit=50&seed_genres=\(seeds)"), type: .GET) { request in
            URLSession.shared.dataTask(with: request) { data, _, error in
                guard let data = data, error == nil else {
                    completion(.failure(APIError.FaliedToGetRecommendations))
                    return
                }

                do {
                    let results = try JSONDecoder().decode(RecommendationsResponce.self, from: data)
                    completion(.success(results))
                } catch {
                    print(error.localizedDescription)
                    completion(.failure(error))
                }
            }.resume()
        }
    }
    
    public func getRecommendedGenres(completion: @escaping (Result<RecommendedGenresResponce, Error>) -> Void) {
        createRequest(with: URL(string: Constants.baseAPIURL+"/recommendations/available-genre-seeds"), type: .GET) { request in
            URLSession.shared.dataTask(with: request) { data, _, error in
                guard let data = data, error == nil else {
                    completion(.failure(APIError.FaliedToGetRecommendedGenres))
                    return
                }

                do {
                    let result = try JSONDecoder().decode(RecommendedGenresResponce.self, from: data)
                    completion(.success(result))
                } catch {
                    print(error.localizedDescription)
                    completion(.failure(error))
                }
            }.resume()
        }
    }
}
