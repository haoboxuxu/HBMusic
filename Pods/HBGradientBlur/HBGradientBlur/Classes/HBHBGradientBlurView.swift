//
//  GradientView.swift
//  HBGradientBlur
//
//  Created by 徐浩博 on 2021/12/7.
//

import UIKit

public class HBHBGradientBlurView: UIView {
    
    private let gradientLayer = CAGradientLayer()
    
    public init() {
        super.init(frame: .zero)
        layer.addSublayer(gradientLayer)
    }
    
    public init(_ colors: [CGColor]) {
        super.init(frame: .zero)
        gradientLayer.colors = colors
        
        layer.addSublayer(gradientLayer)
    }
    
    public init(_ image: UIImage) {
        super.init(frame: .zero)
        config(image)
    }
    
    public func config(_ image: UIImage) {
        let images = image.split2Images()
        
        if let imgTopColor = images[0].averageColor?.cgColor, let imgBottomColor = images[1].averageColor?.cgColor {
            gradientLayer.colors = [
                imgTopColor, imgBottomColor
            ]
        }
    }
    
    public func config(_ colors: [CGColor]) {
        gradientLayer.colors = colors
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        gradientLayer.frame = bounds
    }
}
