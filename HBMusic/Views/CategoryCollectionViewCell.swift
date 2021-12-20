//
//  GenreCollectionViewCell.swift
//  HBMusic
//
//  Created by 徐浩博 on 2021/11/29.
//

import UIKit

class CategoryCollectionViewCell: UICollectionViewCell {
    static let identifier = "GenreCollectionViewCell"
    
    private var imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(systemName: "music.note.list", withConfiguration: UIImage.SymbolConfiguration(pointSize: 50, weight: .regular))
        imageView.contentMode = .scaleAspectFill
        imageView.layer.masksToBounds = true
        return imageView
    }()
    
    private var label: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.textColor = .white
        label.font = .systemFont(ofSize: 18, weight: .semibold )
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.addSubview(imageView)
        contentView.addSubview(label)
        contentView.layer.cornerRadius = 12
        contentView.layer.masksToBounds = true
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        imageView.frame = bounds
        label.frame = CGRect(x: 10, y: height-44, width: width-20, height: 44)
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        label.text = nil
        imageView.image = UIImage(systemName: "music.note.list", withConfiguration: UIImage.SymbolConfiguration(pointSize: 50, weight: .regular))
    }
    
    func config(with viewModel: CategoryCollectionVM) {
        label.text = viewModel.title
        imageView.hbSetImage(with: viewModel.artworkURL, placeholderImage: nil, completion: nil)
    }
}
