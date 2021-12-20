//
//  HBWebImageCache.swift
//  HBWebImage
//
//  Created by 徐浩博 on 2021/11/22.
//

import Foundation
import UIKit

class HBWebImageCacheManger {
    
    static func fetchCachedImage(urlStr: String) -> UIImage? {
        let key = getKey(from: urlStr)
        if let cachedImage = HBWebImageMemoryManager.shared.fetchImageFromMemory(with: key) {
            if __HBWebImageDevmode {
                print("👾HBWebImageCacheManger: fetchCachedImage from Memory success")
            }
            return cachedImage
        }
        
        if let data = HBWebImageDiskManager.shared.fetchDataFromDisk(with: key) {
            let cachedImage = UIImage(data: data)
            if __HBWebImageDevmode {
                print("👾HBWebImageCacheManger: fetchCachedImage from Disk success")
            }
            HBWebImageMemoryManager.shared.saveImageToMemory(image: UIImage(data: data)!, with: key)
            return cachedImage
        }
        if __HBWebImageDevmode {
            print("👾HBWebImageCacheManger: fetchCachedImage failed")
        }
        return nil
    }
    
    static func saveImage(data: Data, urlStr: String) {
        let key = getKey(from: urlStr)
        if let image = UIImage(data: data) {
            HBWebImageMemoryManager.shared.saveImageToMemory(image: image, with: key)
            HBWebImageDiskManager.shared.saveDataToDisk(data: data, with: key)
        }
    }
    
    static func removeAllCached() {
        HBWebImageMemoryManager.shared.removeAllMenmoryCached()
        HBWebImageDiskManager.shared.removeAllDiskCached()
    }
    
    static func removeImage(urlStr: String) {
        let key = getKey(from: urlStr)
        HBWebImageMemoryManager.shared.removeImageFromMemory(with: key)
        HBWebImageDiskManager.shared.removeDataFromDisk(with: key)
    }
    
    static func memoryCachedSize() -> Int {
        HBWebImageMemoryManager.shared.memoryCachedSize()
    }
    
    static func diskCachedSize() -> Int {
        HBWebImageDiskManager.shared.diskCachedSize()
    }
    
    private static func getKey(from urlStr: String) -> NSNumber {
        return urlStr.safeHash
    }
}
