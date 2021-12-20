//
//  FeaturedPlaylistsResponce.swift
//  HBMusic
//
//  Created by 徐浩博 on 2021/11/21.
//

import Foundation

struct FeaturedPlaylistsResponce: Codable {
    let playlists: PlaylistsResponce
}

struct CatagoryPlaylistsResponce: Codable {
    let playlists: PlaylistsResponce
}

struct PlaylistsResponce: Codable {
    let items: [Playlist]
}

struct Playlist: Codable {
    let description: String
    let external_urls: [String: String]
    let id: String
    let images: [APIImage]
    let name: String
    let owner: Owner
}

struct Owner: Codable {
    let display_name: String
    let external_urls: [String: String]
    let id: String
}
