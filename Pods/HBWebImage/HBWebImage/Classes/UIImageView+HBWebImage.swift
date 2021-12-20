//
//  UIImageView+HBWebImage.swift
//  HBWebImage
//
//  Created by 徐浩博 on 2021/11/24.
//

import UIKit

extension UIImageView: HBWebImageProtocol {
    
    public func hbSetImageDevMode(with url: URL?, placeholderImage: UIImage? = nil, completion: ((UIImage?) -> Void)? = nil) {
        __HBWebImageDevmode = true
        self.__hbSetImage(with: url, placeholderImage: placeholderImage, completion: nil)
    }
    
    public func hbSetImage(with url: URL?, placeholderImage: UIImage? = nil, completion: ((UIImage?) -> Void)? = nil) {
        self.__hbSetImage(with: url, placeholderImage: placeholderImage, completion: nil)
    }
    
    private func __hbSetImage(with url: URL?, placeholderImage: UIImage? = nil, completion: ((UIImage?) -> Void)? = nil) {
        MainQueue.async {
            if let placeholderImage = placeholderImage {
                self.image = placeholderImage
            }
        }
        guard let url = url else {
            print("url error")
            completion?(nil)
            return
        }
        if let cachedImage = HBWebImageCacheManger.fetchCachedImage(urlStr: url.absoluteString) {
            MainQueue.async {
                self.image = cachedImage
                completion?(cachedImage)
            }
            return
        }
        
        fetchData(url: url) { result in
            switch result {
            case .success(let data):
                let image = UIImage(data: data)
                MainQueue.async {
                    self.image = image
                    completion?(image)
                }
                StorageQueue.async {
                    HBWebImageCacheManger.saveImage(data: data, urlStr: url.absoluteString)
                }
            case .failure(let error):
                print(error.localizedDescription)
                completion?(nil)
            }
        }
    }
    
}
