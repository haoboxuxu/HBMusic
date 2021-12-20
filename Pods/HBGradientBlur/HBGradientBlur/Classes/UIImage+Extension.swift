//
//  ext.swift
//  HBGradientBlur
//
//  Created by 徐浩博 on 2021/12/8.
//

import UIKit

extension UIImage {
    
    func split4Images() -> [UIImage] {
        let imgWidth = self.size.width / 2
        let imgHeight = self.size.height / 2
        var imgImages:[UIImage] = []

        let leftHigh = CGRect(x: 0, y: 0, width: imgWidth, height: imgHeight)
        let rightHigh = CGRect(x: imgWidth, y: 0, width: imgHeight, height: imgHeight)
        let leftLow = CGRect(x: 0, y: imgHeight, width: imgWidth, height: imgHeight)
        let rightLow = CGRect(x: imgWidth, y: imgHeight, width: imgWidth, height: imgHeight)

        let leftQH = self.cgImage?.cropping(to:leftHigh)
        let rightHQ = self.cgImage?.cropping(to:rightHigh)
        let leftQL = self.cgImage?.cropping(to:leftLow)
        let rightQL = self.cgImage?.cropping(to:rightLow)

        imgImages.append(UIImage(cgImage: leftQH!))
        imgImages.append(UIImage(cgImage: rightHQ!))
        imgImages.append(UIImage(cgImage: leftQL!))
        imgImages.append(UIImage(cgImage: rightQL!))

        return imgImages
    }
    
    func split2Images() -> [UIImage] {
        let imgWidth = self.size.width
        let imgHeight = self.size.height / 2
        var imgImages:[UIImage] = []

        let top = CGRect(x: 0, y: 0, width: imgWidth, height: imgHeight)
        let bottom = CGRect(x: 0, y: imgHeight, width: imgWidth, height: imgHeight)

        let leftQH = self.cgImage?.cropping(to:top)
        let rightHQ = self.cgImage?.cropping(to:bottom)

        imgImages.append(UIImage(cgImage: leftQH!))
        imgImages.append(UIImage(cgImage: rightHQ!))

        return imgImages
    }
    
    var averageColor: UIColor? {
        guard let ciImage = CIImage(image: self) else {
            return nil
        }

        let extentVector = CIVector(x: ciImage.extent.origin.x, y: ciImage.extent.origin.y, z: ciImage.extent.size.width, w: ciImage.extent.size.height)

        guard let filter = CIFilter(name: "CIAreaAverage", parameters: [kCIInputImageKey: ciImage, kCIInputExtentKey: extentVector]) else { return nil }
        guard let outputImage = filter.outputImage else { return nil }

        var bitmap = [UInt8](repeating: 0, count: 4)

        let context = CIContext(options: [.workingColorSpace: kCFNull!])
        context.render(outputImage, toBitmap: &bitmap, rowBytes: 4, bounds: CGRect(x: 0, y: 0, width: 1, height: 1), format: .RGBA8, colorSpace: nil)

        return UIColor(red: CGFloat(bitmap[0]) / 255, green: CGFloat(bitmap[1]) / 255, blue: CGFloat(bitmap[2]) / 255, alpha: CGFloat(bitmap[3]) / 255)
    }
}
