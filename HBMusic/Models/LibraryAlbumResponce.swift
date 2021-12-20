//
//  LibraryAlbumResponce.swift
//  HBMusic
//
//  Created by 徐浩博 on 2021/12/19.
//

import Foundation

struct LibraryAlbumResponce: Codable {
    let items: [SavedAlbum]
}

struct SavedAlbum: Codable {
    let added_at: String
    let album: Album
}
