//
//  Extensions.swift
//  HBMusic
//
//  Created by 徐浩博 on 2021/11/17.
//

import UIKit

extension UIView {
    var width: CGFloat {
        return frame.size.width
    }
    
    var height: CGFloat {
        return frame.size.height
    }
    
    var left: CGFloat {
        return frame.origin.x
    }
    
    var right: CGFloat {
        return left + width
    }
    
    var top: CGFloat {
        return frame.origin.y
    }
    
    var bottom: CGFloat {
        return top + height
    }
}

extension NSNotification.Name {
    static let kAlbumSavedNotification = Notification.Name("AlbumSavedNotification")
}
