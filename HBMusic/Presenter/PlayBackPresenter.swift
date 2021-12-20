//
//  PlayBackPresenter.swift
//  HBMusic
//
//  Created by 徐浩博 on 2021/12/2.
//

import UIKit
import AVFoundation

protocol PlayBackDataSource: AnyObject {
    var trackName: String? { get }
    var artistName: String? { get }
    var imageURL: URL? { get }
}

final class PlayBackPresenter {
    
    static let shared = PlayBackPresenter()
    
    private var track: AudioTrack?
    private var tracks: [AudioTrack] = []
    
    var player: AVPlayer?
    var queuePlayer: AVQueuePlayer?
    
    var playerVC: PlayerVC?
    
    var currentTrack: AudioTrack? {
        if let track = track, tracks.isEmpty {
            return track
        } else if let queuePlayer = queuePlayer, !tracks.isEmpty {
            let item = queuePlayer.currentItem
            let items = queuePlayer.items()
            guard let index = items.firstIndex(where: { playerItem in
                playerItem == item
            }) else {
                return nil
            }
            return tracks[index]
        }
        return nil
    }
    
    private init() {}
    
    func startPlayBack(in viewColtroller: UIViewController, with track: AudioTrack) {
        self.track = track
        self.tracks = []
        
        guard let url = URL(string: track.preview_url ?? "") else {
            print("startPlayBack track url nil")
            return
        }
        player = AVPlayer(url: url)
        //let asset = AVURLAsset(url: url)
        //let keys = ["playable"]
        player?.volume = 0.5
        
        let playerVC = PlayerVC()
        playerVC.dataSource = self
        playerVC.delegate = self
        
        viewColtroller.present(playerVC, animated: true) {
            self.player?.play()
            self.playerVC = playerVC
            self.playerVC?.reloadUI()
        }
    }
    
    func startPlayBack(in viewColtroller: UIViewController, with tracks: [AudioTrack]) {
        self.tracks = tracks
        self.track = nil
        
        self.queuePlayer = AVQueuePlayer(items: tracks.compactMap {
            guard let url = URL(string: $0.preview_url ?? "") else {
                return nil
            }
            return AVPlayerItem(url: url)
        })
        self.queuePlayer?.volume = 0.5
        
        let playerVC = PlayerVC()
        playerVC.dataSource = self
        playerVC.delegate = self
        
        viewColtroller.present(playerVC, animated: true) {
            self.queuePlayer?.play()
            self.playerVC = playerVC
            self.playerVC?.reloadUI()
        }
    }
}

extension PlayBackPresenter: PlayerVCDelegate {
    func didSlideVolume(_ value: Float) {
        player?.volume = value
        queuePlayer?.volume = value
    }
    
    func didTapBackButton() {
        if tracks.isEmpty {
            player?.pause()
            player?.play()
        } else if let firstItem = queuePlayer?.items().first {
            queuePlayer?.pause()
            queuePlayer?.removeAllItems()
            queuePlayer = AVQueuePlayer(items: [firstItem])
            queuePlayer?.volume = 0
        }
    }
    
    func didTapForwardButton() {
        if tracks.isEmpty {
            player?.pause()
        } else if let queuePlayer = queuePlayer {
            queuePlayer.advanceToNextItem()
        }
    }
    
    func didTapPlayPauseButton() {
        if let player = player {
            if player.timeControlStatus == .playing {
                player.pause()
            } else if player.timeControlStatus == .paused {
                player.play()
            }
        } else if let queuePlayer = queuePlayer {
            if queuePlayer.timeControlStatus == .playing {
                queuePlayer.pause()
            } else if queuePlayer.timeControlStatus == .paused {
                queuePlayer.play()
            }
        }
    }
}

extension PlayBackPresenter: PlayBackDataSource {
    var trackName: String? {
        currentTrack?.name
    }
    
    var artistName: String? {
        currentTrack?.artists.first?.name
    }
    
    var imageURL: URL? {
        URL(string: currentTrack?.album?.images.first?.url ?? "")
    }
}
