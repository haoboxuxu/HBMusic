//
//  APICaller-Browse.swift
//  HBMusic
//
//  Created by 徐浩博 on 2021/12/19.
//

import Foundation

extension APICaller {
    public func getNewReleases(completion: @escaping (Result<NewReleasesResponce, Error>) -> Void) {
        createRequest(with: URL(string: Constants.baseAPIURL+"/browse/new-releases?limit=50"), type: .GET) { request in
            URLSession.shared.dataTask(with: request) { data, _, error in
                guard let data = data, error == nil else {
                    completion(.failure(APIError.FaliedToGetFeaturedPlaylists))
                    return
                }

                do {
                    let results = try JSONDecoder().decode(NewReleasesResponce.self, from: data)
                    completion(.success(results))
                } catch {
                    print(error.localizedDescription)
                    completion(.failure(error))
                }
            }.resume()
        }
    }
}
