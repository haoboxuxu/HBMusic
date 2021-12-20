//
//  NewReleasesResponce.swift
//  HBMusic
//
//  Created by 徐浩博 on 2021/11/21.
//

import Foundation

struct NewReleasesResponce: Codable {
    let albums: AlbumsResponce
}

struct AlbumsResponce: Codable {
    let items: [Album]
}

struct Album: Codable {
    let album_type: String
    let available_markets: [String]
    let id: String
    var images: [APIImage]
    let name: String
    let release_date: String
    let total_tracks: Int
    let artists: [Artist]
}
