//
//  APICaller-Album.swift
//  HBMusic
//
//  Created by 徐浩博 on 2021/12/19.
//

import Foundation

extension APICaller {
    public func getAlbumDetail(for album: Album, completion: @escaping (Result<AlbumDetailsResponce, Error>) -> Void) {
        createRequest(with: URL(string: Constants.baseAPIURL+"/albums/\(album.id)"), type: .GET) { request in
            URLSession.shared.dataTask(with: request) { data, _, error in
                guard let data = data, error == nil else {
                    completion(.failure(APIError.FaliedToGetData))
                    return
                }

                do {
                    let results = try JSONDecoder().decode(AlbumDetailsResponce.self, from: data)
                    completion(.success(results))
                } catch {
                    print(error.localizedDescription)
                    completion(.failure(error))
                }
            }.resume()
        }
    }
    
    public func getSavedAlbums(completion: @escaping (Result<[Album], Error>) -> Void) {
        createRequest(with: URL(string: Constants.baseAPIURL + "/me/albums/?limit=50"), type: .GET) { request in
            URLSession.shared.dataTask(with: request) { data, _, error in
                guard let data = data, error == nil else {
                    completion(.failure(APIError.FaliedToGetData))
                    return
                }

                do {
                    let results = try JSONDecoder().decode(LibraryAlbumResponce.self, from: data)
                    completion(.success(results.items.compactMap({ savedAlbum in
                        savedAlbum.album
                    })))
                } catch {
                    print(error.localizedDescription)
                    completion(.failure(error))
                }
            }.resume()
        }
    }
    
    public func saveAlbums(ids: String, completion: @escaping (Bool) -> Void) {
        createRequest(with: URL(string: Constants.baseAPIURL + "/me/albums?ids=\(ids)"), type: .PUT) { baseRequest in
            var request = baseRequest
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            
            URLSession.shared.dataTask(with: request) { _, responce, _ in
                if let code = (responce as? HTTPURLResponse)?.statusCode, code == 200 || code == 201 {
                    completion(true)
                    return
                }
                completion(false)
            }.resume()
        }
    }
//
//    public func addTrackToPlaylist(track: AudioTrack, playlist: Playlist, completion: @escaping (Bool) -> Void) {
//        createRequest(with: URL(string: Constants.baseAPIURL + "/playlists/\(playlist.id)/tracks"), type: .POST) { baseRequest in
//            var request = baseRequest
//            let json = [
//                "uris": [
//                    "spotify:track:\(track.id)"
//                ]
//            ]
//            request.httpBody = try? JSONSerialization.data(withJSONObject: json, options: .fragmentsAllowed)
//            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
//
//            URLSession.shared.dataTask(with: request) { data, _, error in
//                guard let data = data, error == nil else {
//                    completion(false)
//                    return
//                }
//
//                do {
//                    let result = try JSONSerialization.jsonObject(with: data, options: .allowFragments)
//                    if let responce = result as? [String: Any], responce["snapshot_id"] as? String != nil {
//                        completion(true)
//                    } else {
//                        completion(false)
//                    }
//                } catch {
//                    print(error.localizedDescription)
//                    completion(false)
//                }
//            }.resume()
//        }
//    }
//
//    public func removeTrackFromPlaylist(track: AudioTrack, playlist: Playlist, completion: @escaping (Bool) -> Void) {
//        createRequest(with: URL(string: Constants.baseAPIURL + "/playlists/\(playlist.id)/tracks"), type: .DELETE) { baseRequest in
//            var request = baseRequest
//            let json = [
//                "tracks": [
//                    [
//                        "uri": "spotify:track:\(track.id)"
//                    ]
//                ]
//            ]
//            request.httpBody = try? JSONSerialization.data(withJSONObject: json, options: .fragmentsAllowed)
//            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
//
//            URLSession.shared.dataTask(with: request) { data, _, error in
//                guard let data = data, error == nil else {
//                    completion(false)
//                    return
//                }
//
//                do {
//                    let result = try JSONSerialization.jsonObject(with: data, options: .allowFragments)
//                    if let responce = result as? [String: Any], responce["snapshot_id"] as? String != nil {
//                        completion(true)
//                    } else {
//                        completion(false)
//                    }
//                } catch {
//                    print(error.localizedDescription)
//                    completion(false)
//                }
//            }.resume()
//        }
//    }
}

