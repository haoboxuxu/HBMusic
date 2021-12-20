//
//  SeveralArtistsResponce.swift
//  HBMusic
//
//  Created by 徐浩博 on 2021/11/30.
//

import Foundation

struct SeveralArtistsResponce: Codable {
    let artists: [ArtistResponce]
}

struct ArtistResponce: Codable {
    let id: String
    let images: [APIImage]
    let name: String
    let external_urls: [String: String]
}
