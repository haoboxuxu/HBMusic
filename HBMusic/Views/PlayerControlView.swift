//
//  PlayerControlView.swift
//  HBMusic
//
//  Created by 徐浩博 on 2021/12/2.
//

import UIKit

protocol PlayerControlViewDelegate: AnyObject {
    func playerControlViewDidTapBackButton(_ playerControlView: PlayerControlView)
    func playerControlViewDidTapForwardButton(_ playerControlView: PlayerControlView)
    func playerControlViewDidTapPlayPauseButton(_ playerControlView: PlayerControlView)
    func playerControlView(_ playerControlView: PlayerControlView, didSlideVolume value: Float)
}

struct PlayerControlVM {
    let trackName: String
    let artistName: String
}

final class PlayerControlView: UIView {
    
    private var isPlaying = true
    
    weak var delegate: PlayerControlViewDelegate?
    
    private let volumeSlider: UISlider = {
        let slider = UISlider()
        slider.value = 0.5
        return slider
    }()
    
    private let trackNameLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 1
        label.font = .systemFont(ofSize: 30, weight: .semibold)
        label.tintColor = .label
        label.textAlignment = .left
        return label
    }()
    
    private let artistNameLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 1
        label.font = .systemFont(ofSize: 20, weight: .regular)
        label.tintColor = .label
        label.textAlignment = .left
        return label
    }()
    
    private let backButton: UIButton = {
        let button = UIButton()
        let image = UIImage(systemName: "backward.fill",
                            withConfiguration: UIImage.SymbolConfiguration(pointSize: 30, weight: .semibold))
        button.setImage(image, for: .normal)
        button.tintColor = .label
        return button
    }()
    
    private let forwardButton: UIButton = {
        let button = UIButton()
        let image = UIImage(systemName: "forward.fill",
                            withConfiguration: UIImage.SymbolConfiguration(pointSize: 30, weight: .semibold))
        button.setImage(image, for: .normal)
        button.tintColor = .label
        return button
    }()
    
    private let playPauseButton: UIButton = {
        let button = UIButton()
        let image = UIImage(systemName: "pause.fill",
                            withConfiguration: UIImage.SymbolConfiguration(pointSize: 40, weight: .semibold))
        button.setImage(image, for: .normal)
        button.tintColor = .label
        return button
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .clear
        addSubview(volumeSlider)
        addSubview(trackNameLabel)
        addSubview(artistNameLabel)
        addSubview(backButton)
        addSubview(forwardButton)
        addSubview(playPauseButton)
        
        backButton.addTarget(self, action: #selector(didTapBackButton), for: .touchUpInside)
        forwardButton.addTarget(self, action: #selector(didTapForwardButton), for: .touchUpInside)
        playPauseButton.addTarget(self, action: #selector(didTapPlayPauseButton), for: .touchUpInside)
        volumeSlider.addTarget(self, action: #selector(didSlideVolume(_:)), for: .valueChanged)
        
        clipsToBounds = true
    }
    
    @objc private func didTapBackButton() {
        delegate?.playerControlViewDidTapBackButton(self)
    }
    
    @objc private func didTapForwardButton() {
        delegate?.playerControlViewDidTapForwardButton(self)
    }
    
    @objc private func didTapPlayPauseButton() {
        isPlaying = !isPlaying
        delegate?.playerControlViewDidTapPlayPauseButton(self)
        let playImage = UIImage(systemName: "play.fill",
                                withConfiguration: UIImage.SymbolConfiguration(pointSize: 40, weight: .semibold))
        let pauseImage = UIImage(systemName: "pause.fill",
                                 withConfiguration: UIImage.SymbolConfiguration(pointSize: 40, weight: .semibold))
        playPauseButton.setImage(!isPlaying ? playImage : pauseImage, for: .normal)
    }
    
    @objc private func didSlideVolume(_ slider: UISlider) {
        delegate?.playerControlView(self, didSlideVolume: slider.value)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        trackNameLabel.frame = CGRect(x: 0, y: 0, width: width, height: 50)
        artistNameLabel.frame = CGRect(x: 0, y: trackNameLabel.bottom, width: width, height: 50)
        
        let buttonSize: CGFloat = width / 3
        backButton.frame = CGRect(x: 0, y: artistNameLabel.bottom, width: buttonSize, height: buttonSize)
        playPauseButton.frame = CGRect(x: backButton.right, y: artistNameLabel.bottom, width: buttonSize, height: buttonSize)
        forwardButton.frame = CGRect(x: playPauseButton.right, y: artistNameLabel.bottom, width: buttonSize, height: buttonSize)
        
        volumeSlider.frame = CGRect(x: 10, y: forwardButton.bottom, width: width-20, height: 44)
    }
    
    func config(_ viewModel: PlayerControlVM) {
        trackNameLabel.text = viewModel.trackName
        artistNameLabel.text = viewModel.artistName
    }
}
