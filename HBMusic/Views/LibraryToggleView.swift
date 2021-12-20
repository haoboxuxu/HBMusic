//
//  LibraryToggleView.swift
//  HBMusic
//
//  Created by 徐浩博 on 2021/12/6.
//

import UIKit

protocol LibraryToggleViewDelegate: AnyObject {
    func libraryToggleViewDidTapPlaylist(_ libraryToggleView: LibraryToggleView)
    func libraryToggleViewDidTapAlbumButton(_ libraryToggleView: LibraryToggleView)
}

class LibraryToggleView: UIView {
    
    enum IndicatorState {
        case playlist
        case album
    }
    
    var indicatorState: IndicatorState = .playlist
    
    private let indicatorView: UIView = {
        let view = UIView()
        view.backgroundColor = .systemPink
        view.layer.masksToBounds = true
        view.layer.cornerRadius = 4
        return view
    }()
    
    private let playlistButton: UIButton = {
        let button = UIButton()
        button.setTitle("Playlists", for: .normal)
        button.setTitleColor(.label, for: .normal)
        return button
    }()
    
    private let albumButton: UIButton = {
        let button = UIButton()
        button.setTitle("Albums", for: .normal)
        button.setTitleColor(.label, for: .normal)
        return button
    }()
    
    weak var delegate: LibraryToggleViewDelegate?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .systemBackground
        addSubview(playlistButton)
        addSubview(albumButton)
        
        addSubview(indicatorView)
        
        playlistButton.addTarget(self, action: #selector(didTapPlaylistButton), for: .touchUpInside)
        albumButton.addTarget(self, action: #selector(didTapAlbumButton), for: .touchUpInside)
    }
    
    @objc private func didTapPlaylistButton() {
        indicatorState = .playlist
        animateIndicatorView()
        delegate?.libraryToggleViewDidTapPlaylist(self)
    }
    
    @objc private func didTapAlbumButton() {
        indicatorState = .album
        animateIndicatorView()
        delegate?.libraryToggleViewDidTapAlbumButton(self)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        playlistButton.frame = CGRect(x: 0, y: 0, width: 100, height: 45)
        albumButton.frame = CGRect(x: playlistButton.right, y: 0, width: 100, height: 45)
        
        layoutIndicatorView()
    }
    
    private func layoutIndicatorView() {
        switch indicatorState {
        case .playlist:
            indicatorView.frame = CGRect(x: 0, y: playlistButton.bottom, width: 100, height: 4)
        case .album:
            indicatorView.frame = CGRect(x: playlistButton.right, y: playlistButton.bottom, width: 100, height: 4)
        }
    }
    
    private func animateIndicatorView() {
        UIView.animate(withDuration: 0.3) {
            self.layoutIndicatorView()
        }
    }
    
    func updateIndicatorView(for state: IndicatorState) {
        self.indicatorState = state
        animateIndicatorView()
    }
}
