//
//  PlayerVC.swift
//  HBMusic
//
//  Created by 徐浩博 on 2021/11/17.
//

import UIKit
import HBGradientBlur

protocol PlayerVCDelegate: AnyObject {
    func didTapBackButton()
    func didTapForwardButton()
    func didTapPlayPauseButton()
    func didSlideVolume(_ value: Float)
}

class PlayerVC: UIViewController {
    
    let gradientView = HBHBGradientBlurView()
    
    weak var dataSource: PlayBackDataSource?
    weak var delegate: PlayerVCDelegate?
    
    private let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.image = UIImage(systemName: "music.note")
        imageView.layer.masksToBounds = true
        imageView.layer.cornerRadius = 12
        return imageView
    }()
    
    private let controlView: PlayerControlView = {
        let controlView = PlayerControlView()
        return controlView
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        view.addSubview(imageView)
        view.addSubview(controlView)
        
        view.addSubview(gradientView)
        gradientView.layer.zPosition = -1
        
        controlView.delegate = self
        configPlayerControlView()
    }
    
    private func configPlayerControlView() {
        imageView.hbSetImage(with: dataSource?.imageURL, placeholderImage: nil, completion: nil)
        controlView.config(PlayerControlVM(trackName: dataSource?.trackName ?? "", artistName: dataSource?.artistName ?? ""))
        gradientView.config(imageView.image!)
    }
    
    public func reloadUI() {
        configPlayerControlView()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        gradientView.frame = view.bounds
        let imageSize = view.width / 2
        imageView.frame = CGRect(x: (view.width-imageSize)/2, y: 100, width: imageSize, height: imageSize)
        controlView.frame = CGRect(x: 25,
                                   y: imageView.bottom+100,
                                   width: view.width-50,
                                   height: view.height-imageView.bottom-view.safeAreaInsets.bottom-view.safeAreaInsets.top-20)
    }
}

extension PlayerVC: PlayerControlViewDelegate {
    func playerControlViewDidTapBackButton(_ playerControlView: PlayerControlView) {
        delegate?.didTapBackButton()
    }
    
    func playerControlViewDidTapForwardButton(_ playerControlView: PlayerControlView) {
        delegate?.didTapForwardButton()
    }
    
    func playerControlViewDidTapPlayPauseButton(_ playerControlView: PlayerControlView) {
        delegate?.didTapPlayPauseButton()
    }
    func playerControlView(_ playerControlView: PlayerControlView, didSlideVolume value: Float) {
        delegate?.didSlideVolume(value)
    }
}
