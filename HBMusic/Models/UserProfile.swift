//
//  Profile.swift
//  HBMusic
//
//  Created by 徐浩博 on 2021/11/17.
//

import Foundation

struct UserProfile: Codable {
    let country: String
    let display_name: String
    let email: String
    let explicit_content: [String: Bool]
    let external_urls: [String: String]
    let id: String
    let product: String
    let images: [APIImage]
}
