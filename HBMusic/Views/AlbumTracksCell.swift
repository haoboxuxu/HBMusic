//
//  AlbumTracksCell.swift
//  HBMusic
//
//  Created by 徐浩博 on 2021/11/28.
//

import UIKit

class AlbumTracksCell: UICollectionViewCell {
    static let identifier = "AlbumTracksCell"
    
    private var albumCoverImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(systemName: "music.note.list")
        imageView.tintColor = .systemPink
        imageView.contentMode = .scaleAspectFill
        imageView.layer.masksToBounds = true
        imageView.layer.cornerRadius = 5
        imageView.backgroundColor = .quaternaryLabel
        return imageView
    }()
    
    private var trackNameLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.font = .systemFont(ofSize: 18, weight: .regular)
        return label
    }()
    
    private var artistNameLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.font = .systemFont(ofSize: 15, weight: .thin)
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.addSubview(albumCoverImageView)
        contentView.addSubview(trackNameLabel)
        contentView.addSubview(artistNameLabel)
        contentView.clipsToBounds = true
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        albumCoverImageView.frame = CGRect(x: 5, y: 2, width: contentView.height/2, height: contentView.height/2)
        trackNameLabel.frame = CGRect(x: albumCoverImageView.right+10, y: 0,
                                      width: contentView.width-albumCoverImageView.right-15, height: contentView.height/2)
        artistNameLabel.frame = CGRect(x: albumCoverImageView.right+10, y: contentView.height/2,
                                       width: contentView.width-albumCoverImageView.right-15, height: contentView.height/2)
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        trackNameLabel.text = nil
        artistNameLabel.text = nil
    }
    
    func config(with viewModel: AlbumTracksCellVM) {
        trackNameLabel.text = viewModel.name
        artistNameLabel.text = viewModel.artistName
    }
}
