//
//  HelperFunc.swift
//  HBWebImage
//
//  Created by 徐浩博 on 2021/11/22.
//

import UIKit

extension String {
    var safeHash: NSNumber {
        let mod = Int32.max
        var safeHash = 0
        for scalar in self.unicodeScalars {
            safeHash = (safeHash * 131 + Int(scalar.value)) % Int(mod)
        }
        return NSNumber(value: safeHash)
    }
}


extension UIImage {
    var sizeInBytes: Int {
        guard let cgImage = self.cgImage else {
            // This won't work for CIImage-based UIImages
            assertionFailure()
            return 0
        }
        return cgImage.bytesPerRow * cgImage.height
    }
}
