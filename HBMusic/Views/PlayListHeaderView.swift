//
//  PlayListHeaderView.swift
//  HBMusic
//
//  Created by 徐浩博 on 2021/11/28.
//

import UIKit

protocol PlayListHeaderViewDelegate: AnyObject {
    func playListHeaderViewDidTapPlay(_ header: PlayListHeaderView)
    func playListHeaderViewDidTapShuffle(_ header: PlayListHeaderView)
}

class PlayListHeaderView: UICollectionReusableView {
    static let identifier = "PlayListHeaderView"
    
    weak var delegate: PlayListHeaderViewDelegate?
    
    private let nameLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 22, weight: .semibold)
        label.textAlignment = .center
        return label
    }()
    
    private let descriptionLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 15, weight: .regular)
        label.textAlignment = .center
        return label
    }()
    
    private let ownerLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 13, weight: .light)
        label.textAlignment = .center
        return label
    }()
    
    private let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.image = UIImage(systemName: "music.note")
        imageView.layer.masksToBounds = true
        imageView.layer.cornerRadius = 12
        return imageView
    }()
    
    private let playButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = .quaternaryLabel
        button.setImage(UIImage(systemName: "play.fill"), for: .normal)
        button.tintColor = .systemPink
        button.layer.cornerRadius = 10
        button.layer.masksToBounds = true
        button.setTitle(" Play", for: .normal)
        button.setTitleColor(.systemPink, for: .normal)
        return button
    }()
    
    private let shuffleButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = .quaternaryLabel
        button.setImage(UIImage(systemName: "shuffle"), for: .normal)
        button.tintColor = .systemPink
        button.layer.cornerRadius = 10
        button.layer.masksToBounds = true
        button.setTitle(" Shuffle", for: .normal)
        button.setTitleColor(.systemPink, for: .normal)
        return button
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .systemBackground
        addSubview(imageView)
        addSubview(nameLabel)
        addSubview(descriptionLabel)
        addSubview(ownerLabel)
        addSubview(playButton)
        addSubview(shuffleButton)
        playButton.addTarget(self, action: #selector(didTapPlay), for: .touchUpInside)
        shuffleButton.addTarget(self, action: #selector(didTapShuffle), for: .touchUpInside)
    }
    
    @objc private func didTapPlay() {
        delegate?.playListHeaderViewDidTapPlay(self)
    }
    
    @objc private func didTapShuffle() {
        delegate?.playListHeaderViewDidTapShuffle(self)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        let imageSize = width / 1.5
        imageView.frame = CGRect(x: (width-imageSize)/2, y: 20, width: imageSize, height: imageSize)
        nameLabel.frame = CGRect(x: 10, y: imageView.bottom+10, width: width-20, height: 44)
        descriptionLabel.frame = CGRect(x: 10, y: nameLabel.bottom, width: width-20, height: 20)
        ownerLabel.frame = CGRect(x: 10, y: descriptionLabel.bottom, width: width-20, height: 20)
        let btnWidth = (width / 2) - 30
        playButton.frame = CGRect(x: 15, y: ownerLabel.bottom+10, width: btnWidth, height: 44)
        shuffleButton.frame = CGRect(x: width/2+15, y: ownerLabel.bottom+10, width: btnWidth, height: 44)
    }
    
    func config(with viewModel: PlayListHeaderVM) {
        imageView.hbSetImage(with: viewModel.artWorkURL, placeholderImage: nil, completion: nil)
        nameLabel.text = viewModel.playlistName
        descriptionLabel.text = viewModel.playlistDescription
        ownerLabel.text = viewModel.ownerName
    }
}
