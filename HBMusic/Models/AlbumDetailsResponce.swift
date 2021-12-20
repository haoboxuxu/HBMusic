//
//  AlbumDetailsResponce.swift
//  HBMusic
//
//  Created by 徐浩博 on 2021/11/27.
//

import Foundation

struct AlbumDetailsResponce: Codable {
    let album_type: String
    let artists: [Artist]
    let available_markets: [String]
    let external_urls: [String: String]
    let id: String
    let images: [APIImage]
    let label: String
    let name: String
    let tracks: TrackResponce
}
