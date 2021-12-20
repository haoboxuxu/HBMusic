//
//  NewReleasesCell.swift
//  HBMusic
//
//  Created by 徐浩博 on 2021/11/23.
//

import UIKit

class NewReleasesCell: UICollectionViewCell {
    static let identifier = "NewReleasesCell"
    
    private var albumCoverImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(systemName: "music.quarternote.3")
        imageView.contentMode = .scaleAspectFill
        imageView.layer.masksToBounds = true
        imageView.layer.cornerRadius = 10
        return imageView
    }()
    
    private var albumNameLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.font = .systemFont(ofSize: 20, weight: .semibold)
        return label
    }()
    
    private var numberOfTracksLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.font = .systemFont(ofSize: 15, weight: .thin)
        return label
    }()
    
    private var artistNameLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.font = .systemFont(ofSize: 18, weight: .light)
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.addSubview(albumCoverImageView)
        contentView.addSubview(albumNameLabel)
        contentView.addSubview(numberOfTracksLabel)
        contentView.addSubview(artistNameLabel)
        contentView.clipsToBounds = true
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        let imageSize = contentView.height - 10
        let albumNameLabelSize = albumNameLabel.sizeThatFits(CGSize(width: contentView.width-imageSize-10, height: contentView.height-10))
        numberOfTracksLabel.sizeToFit()
        artistNameLabel.sizeToFit()
        
        albumCoverImageView.frame = CGRect(x: 5, y: 5, width: imageSize, height: imageSize)
        
        let albumNameLabelHeight = min(60, albumNameLabelSize.height)
        
        albumNameLabel.frame = CGRect(x: albumCoverImageView.right+10,
                                      y: 5,
                                      width: albumNameLabelSize.width,
                                      height: albumNameLabelHeight)
        
        artistNameLabel.frame = CGRect(x: albumCoverImageView.right+10,
                                       y: albumNameLabel.bottom,
                                       width: contentView.width-albumCoverImageView.right-10,
                                       height: 30)
        
        numberOfTracksLabel.frame = CGRect(x: albumCoverImageView.right+10,
                                           y: contentView.bottom-44,
                                           width: numberOfTracksLabel.width,
                                           height: 44)
        
       
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        albumNameLabel.text = nil
        artistNameLabel.text = nil
        numberOfTracksLabel.text = nil
        albumCoverImageView.image = nil
    }
    
    func config(with viewModel: NewReleasesCellVM) {
        albumNameLabel.text = viewModel.name
        artistNameLabel.text = viewModel.artistName
        numberOfTracksLabel.text = "Tracks: \(viewModel.numberOfTracks)"
        albumCoverImageView.hbSetImage(with: viewModel.artWorkURL, placeholderImage: nil, completion: nil)
    }
}
