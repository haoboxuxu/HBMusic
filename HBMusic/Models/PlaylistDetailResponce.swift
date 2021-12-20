//
//  PlaylistDetailResponce.swift
//  HBMusic
//
//  Created by 徐浩博 on 2021/11/27.
//

import Foundation

struct PlaylistDetailResponce: Codable {
    let description: String
    let external_urls: [String: String]
    let id: String
    let images: [APIImage]
    let name: String
    //let `public`: Bool
    let tracks: PlaylistTrackResponce
}

struct PlaylistTrackResponce: Codable {
    let items: [PlaylistItem]
}

struct PlaylistItem: Codable {
    let track: AudioTrack
}
