//
//  SeveralCategoriesResponce.swift
//  HBMusic
//
//  Created by 徐浩博 on 2021/11/30.
//

import Foundation

struct SeveralCategoriesResponce: Codable {
    let categories: Catagories
}

struct Catagories: Codable {
    let items: [MusicCategory]
}

struct MusicCategory: Codable {
    let id: String
    let icons: [APIImage]
    let name: String
}
