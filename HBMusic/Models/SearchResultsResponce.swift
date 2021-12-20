//
//  SearchResultsResponce.swift
//  HBMusic
//
//  Created by 徐浩博 on 2021/12/1.
//

import Foundation

struct SearchResultsResponce: Codable {
    let albums: SearchAlbumsResponce
    let artists: SearchArtistsResponce
    let playlists: SearchPlaylistsResponce
    let tracks: SearchTracksResponce
}

struct SearchAlbumsResponce: Codable {
    let items: [Album]
}

struct SearchArtistsResponce: Codable {
    let items: [Artist]
}

struct SearchPlaylistsResponce: Codable {
    let items: [Playlist]
}

struct SearchTracksResponce: Codable {
    let items: [AudioTrack]
}

enum SearchResult {
    case album(model: Album)
    case artist(model: Artist)
    case playlist(model: Playlist)
    case track(model: AudioTrack)
}
