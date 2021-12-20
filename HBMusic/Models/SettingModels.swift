//
//  SettingModel.swift
//  HBMusic
//
//  Created by 徐浩博 on 2021/11/19.
//

import Foundation

struct Section {
    let title: String
    let option: [Option]
}

struct Option {
    let title: String
    let handler: (() -> Void)
}
