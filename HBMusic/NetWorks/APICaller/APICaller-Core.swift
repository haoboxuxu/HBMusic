//
//  APICaller.swift
//  HBMusic
//
//  Created by 徐浩博 on 2021/11/17.
//

import Foundation

final class APICaller {
    static let shared = APICaller()
    
    private init() {}
    
    struct Constants {
        static let baseAPIURL = "https://api.spotify.com/v1"
    }
    
    struct RequestBody {
        let value: String
        let headerField: String
    }
    
    enum APIError: Error {
        case FaliedToGetData
        case FaliedToGetNewReleases
        case FaliedToGetFeaturedPlaylists
        case FaliedToGetRecommendations
        case FaliedToGetRecommendedGenres
    }
    
    enum HTTPMethod: String {
        case GET
        case POST
        case DELETE
        case PUT
    }
    
    // MARK: BaseRequest
    func createRequest(with url: URL?, type: HTTPMethod, completion: @escaping ((URLRequest) -> Void)) {
        AuthManger.shared.withValidToken { token in
            guard let apiURL = url else { return }
            var request = URLRequest(url: apiURL)
            request.httpMethod = type.rawValue
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
            request.timeoutInterval = 30
            completion(request)
        }
    }
}
