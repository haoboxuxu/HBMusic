//
//  PlayListHeaderVM.swift
//  HBMusic
//
//  Created by 徐浩博 on 2021/11/28.
//

import Foundation

struct PlayListHeaderVM: Codable {
    let playlistName: String?
    let ownerName: String?
    let playlistDescription: String?
    let artWorkURL: URL?
}
