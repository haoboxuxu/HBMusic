//
//  TitleHeaderCRView.swift
//  HBMusic
//
//  Created by 徐浩博 on 2021/11/28.
//

import UIKit

class TitleHeaderCRView: UICollectionReusableView {
    static let identifier = "TitleHeaderCRView"
    
    private var titleLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .left
        label.font = .systemFont(ofSize: 24, weight: .medium)
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(titleLabel)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        titleLabel.frame = CGRect(x: 15, y: 2, width: width-20, height: height)
    }
    
    func config(with title: String) {
        titleLabel.text = title
    }
}
