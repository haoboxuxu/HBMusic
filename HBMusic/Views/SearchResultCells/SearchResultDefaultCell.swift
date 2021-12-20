//
//  SearchResultDefaultCell.swift
//  HBMusic
//
//  Created by 徐浩博 on 2021/12/2.
//

import UIKit

struct SearchResultDefaultCellVM {
    let title: String
    let imageURL: URL?
}

class SearchResultDefaultCell: UITableViewCell {
    
    static let identifier = "SearchResultDefaultCell"
    
    private let label: UILabel = {
        let label = UILabel()
        label.textAlignment = .left
        label.numberOfLines = 1
        return label
    }()
    
    private let coverImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.image = UIImage(systemName: "person.circle.fill")
        imageView.layer.masksToBounds = true
        imageView.layer.cornerRadius = 5
        return imageView
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.addSubview(label)
        contentView.addSubview(coverImageView)
        contentView.clipsToBounds = true
        self.accessoryType = .disclosureIndicator
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        coverImageView.frame = CGRect(x: 10, y: 2, width: contentView.height-4, height: contentView.height-4)
        label.frame = CGRect(x: coverImageView.right+10, y: 0,
                             width: contentView.width-coverImageView.right-15, height: contentView.height)
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        coverImageView.image = nil
        label.text = nil
    }
    
    func config(with viewModel: SearchResultDefaultCellVM) {
        label.text = viewModel.title
        coverImageView.hbSetImage(with: viewModel.imageURL, placeholderImage: nil, completion: nil)
    }
}
