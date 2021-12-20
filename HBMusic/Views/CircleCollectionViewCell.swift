//
//  CircleCollectionViewCell.swift
//  HBMusic
//
//  Created by 徐浩博 on 2021/11/29.
//

import UIKit

class CircleCollectionViewCell: UICollectionViewCell {
    static let identifier = "CircleCollectionViewCell"
    
    private let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.clipsToBounds = true
        imageView.contentMode = .scaleAspectFit
        imageView.layer.masksToBounds = true
        imageView.layer.cornerRadius = 80/2
        imageView.backgroundColor = .black
        imageView.layer.borderColor = UIColor.gray.cgColor
        imageView.layer.borderWidth = 2
        return imageView
    }()
    
    private let label: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 12, weight: .regular)
        label.textAlignment = .center
        label.numberOfLines = 1
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.addSubview(imageView)
        contentView.addSubview(label)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        imageView.frame = CGRect(x: 0, y: 0, width: 80, height: 80)
        label.frame = CGRect(x: 0, y: imageView.bottom, width: contentView.width, height: 20)
    }
    
    public func configure(_ viewModel: ArtistResponce) {
        imageView.hbSetImage(with: URL(string: viewModel.images.first?.url ?? ""), placeholderImage: nil, completion: nil)
        label.text = viewModel.name
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        imageView.image = nil
    }
}
