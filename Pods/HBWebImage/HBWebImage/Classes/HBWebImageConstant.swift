//
//  HBWebImageManager.swift
//  HBWebImage
//
//  Created by 徐浩博 on 2021/11/22.
//

import Foundation

let MainQueue = DispatchQueue.main
let WebImageQueue = DispatchQueue(label: "HBWebImage Download DispatchQueue", attributes: .concurrent)
let StorageQueue = DispatchQueue(label: "HBWebImage Disk&Memory Storage Queue", attributes: .concurrent)
let serialQueue = DispatchQueue(label: "HBWebImage serial wr_queue")
var __HBWebImageDevmode = false
