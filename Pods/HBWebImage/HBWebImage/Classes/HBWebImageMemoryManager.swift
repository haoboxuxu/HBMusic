//
//  SDWebImageMemoryManager.swift
//  HBWebImage
//
//  Created by 徐浩博 on 2021/11/23.
//

import UIKit

class HBWebImageMemoryManager {
    public static let shared = HBWebImageMemoryManager()
    
    private init() {}
    
    private var cache = NSCache<NSNumber, UIImage>()
    private var cachedSize = [NSNumber: Int]()
    private var keyChain: Set<NSNumber> = []
    
    func saveImageToMemory(image: UIImage, with key: NSNumber) {
        //objc_sync_enter(keyChain)
        serialQueue.sync {
            if !keyChain.contains(key) {
                keyChain.insert(key)
            }
        }
        //objc_sync_exit(keyChain)
        cache.setObject(image, forKey: key)
        cachedSize[key] = image.sizeInBytes
        if __HBWebImageDevmode {
            print("👾HBWebImageMemoryManager: saveImageToMemory")
        }
    }
    
    func fetchImageFromMemory(with key: NSNumber) -> UIImage? {
        if !keyChain.contains(key) {
            if __HBWebImageDevmode {
                print("👾HBWebImageMemoryManager: fetchImageFromMemory failed")
            }
            return nil
        }
        if __HBWebImageDevmode {
            print("👾HBWebImageMemoryManager: fetchImageFromMemory success")
        }
        return cache.object(forKey: key)
    }
    
    func removeAllMenmoryCached() {
        keyChain.removeAll()
        cache.removeAllObjects()
    }
    
    func removeImageFromMemory(with key: NSNumber) {
        if keyChain.contains(key) {
            keyChain.remove(key)
            cache.removeObject(forKey: key)
        }
    }
    
    func memoryCachedSize() -> Int {
        var size = 0
        for (_,v) in cachedSize {
            size = size + v
        }
        return size
    }
}
