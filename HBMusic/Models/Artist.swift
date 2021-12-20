//
//  Artist.swift
//  HBMusic
//
//  Created by 徐浩博 on 2021/11/17.
//

import Foundation

struct Artist: Codable {
    let id: String
    let name: String
    let type: String
    let images: [APIImage]?
    let external_urls: [String: String]
}
