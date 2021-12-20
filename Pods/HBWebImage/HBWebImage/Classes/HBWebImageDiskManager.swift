//
//  HBWebImageDiskManager.swift
//  HBWebImage
//
//  Created by 徐浩博 on 2021/11/23.
//

import UIKit

class HBWebImageDiskManager {
    
    public static let shared = HBWebImageDiskManager()
    
    private let DiskCachePath: String
    
    private init() {
        let bundleID = Bundle.main.bundleIdentifier
        DiskCachePath = NSHomeDirectory().appending("/Library").appending("/Caches/").appending(bundleID!).appending("/fsCachedData")
        
        if __HBWebImageDevmode {
            print("NSHomeDirectory = ", NSHomeDirectory())
            print("DiskCachePath = ", DiskCachePath)
        }
    }
    
   
    
    private func fullPath(_ key: NSNumber) -> String {
        DiskCachePath.appending("/\(key)")
    }
    
    func saveDataToDisk(data: Data, with key: NSNumber) {
        let path = fullPath(key)
        if FileManager.default.createFile(atPath: path, contents: data) {
            if __HBWebImageDevmode {
                print("👾HBWebImageDiskManager: saveDataToDisk success")
            }
        } else {
            if __HBWebImageDevmode {
                print("👾HBWebImageDiskManager: saveDataToDisk failed")
            }
        }
    }
    
    func removeDataFromDisk(with key: NSNumber) {
        let path = fullPath(key)
        if FileManager.default.fileExists(atPath: path) {
            do {
                try FileManager.default.removeItem(atPath: path)
            } catch {
                print(error.localizedDescription)
            }
        } else {
            
        }
    }
    
    func fetchDataFromDisk(with key: NSNumber) -> Data? {
        let path = fullPath(key)
        if FileManager.default.fileExists(atPath: path) {
            return FileManager.default.contents(atPath: path)
        } else {
            return nil
        }
    }
    
    func removeAllDiskCached() {
        let path = DiskCachePath
        if FileManager.default.fileExists(atPath: path) {
            do {
                try FileManager.default.removeItem(atPath: path)
            } catch {
                print(error.localizedDescription)
            }
        }
    }
    
    func fileSize(at path: String) -> Int {
        var size: Int = 0
        do {
            let dic = try FileManager.default.attributesOfItem(atPath: path) as NSDictionary
            size = Int(dic.fileSize())
        } catch {
            print(error.localizedDescription)
        }
        return size
    }
    
    func diskCachedSize() -> Int {
        if !FileManager.default.fileExists(atPath: DiskCachePath) {
            return 0
        }
        var size = 0
        for path in FileManager.default.subpaths(atPath: DiskCachePath)! {
            let childPath = "\(DiskCachePath)/\(path)"
            size = size + fileSize(at: childPath)
        }
        return size
    }
}
