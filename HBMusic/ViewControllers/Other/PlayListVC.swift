//
//  PlayListVC.swift
//  HBMusic
//
//  Created by 徐浩博 on 2021/11/27.
//

import UIKit

class PlayListVC: UIViewController {

    private let playlist: Playlist
    
    public var isOwner = false
    
    private let collectionView: UICollectionView = {
        let layout = UICollectionViewCompositionalLayout { index, _ in
            let item = NSCollectionLayoutItem(
                layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalHeight(1.0))
            )
            
            item.contentInsets = NSDirectionalEdgeInsets(top: 2, leading: 2, bottom: 2, trailing: 2)
            
            let group = NSCollectionLayoutGroup.vertical(
                layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .absolute(80)),
                subitem: item,
                count: 1
            )
            
            let section = NSCollectionLayoutSection(group: group)
            let sectionHeader = NSCollectionLayoutBoundarySupplementaryItem(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1),
                                                                                                               heightDimension: .fractionalWidth(1.2)),
                                                                            elementKind: UICollectionView.elementKindSectionHeader,
                                                                             alignment: .top)
            let sectionFooter = NSCollectionLayoutBoundarySupplementaryItem(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1),
                                                                                                               heightDimension: .absolute(150)),
                                                                            elementKind: UICollectionView.elementKindSectionFooter,
                                                                            alignment: .bottom)
            section.boundarySupplementaryItems = [sectionHeader, sectionFooter]
            return section
        }
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .systemBackground
        collectionView.register(
            RecommendedTracksCell.self,
            forCellWithReuseIdentifier: RecommendedTracksCell.identifier
        )
        collectionView.register(
            PlayListHeaderView.self,
            forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
            withReuseIdentifier: PlayListHeaderView.identifier
        )
        collectionView.register(
            ArtistsCollectionView.self,
            forSupplementaryViewOfKind: UICollectionView.elementKindSectionFooter,
            withReuseIdentifier: ArtistsCollectionView.identifier
        )
        return collectionView
    }()
    
    private var viewModels: [RecommendedTracksCellVM] = []
    private var tracks: [AudioTrack] = []
    
    private var footerArtistsIDs = Set<String>()
    private var footerVM: [ArtistResponce] = []
    
    init(_ playlist: Playlist) {
        self.playlist = playlist
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = playlist.name
        view.backgroundColor = .systemBackground
        view.addSubview(collectionView)
        
        
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.prefetchDataSource = self
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .action, target: self, action: #selector(didTapMore))
        
        APICaller.shared.getPlaylistDetail(for: playlist) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let model):
                    self?.tracks = model.tracks.items.compactMap({ item in
                        item.track
                    })
                    self?.viewModels = model.tracks.items.compactMap({ item in
                        return RecommendedTracksCellVM(name: item.track.name,
                                                       artistName: item.track.artists.first?.name ?? "-",
                                                       artWorkURL: URL(string: item.track.album?.images.first?.url ?? ""))
                    })
                    self?.collectionView.reloadData()
                    for item in model.tracks.items {
                        if let id = item.track.artists.first?.id {
                            self?.footerArtistsIDs.insert(id)
                        }
                    }
                    var ids  = ""
                    var count = 0
                    if let footerArtistsIDs = self?.footerArtistsIDs {
                        for id in footerArtistsIDs {
                            if count == 10 {
                                break
                            }
                            ids = ids + id + ","
                            count = count + 1
                        }
                    }
                    if ids.count >= 1 {
                        ids.removeLast()
                    }
                    DispatchQueue.global().async {
                        APICaller.shared.getSeveralArtists(ids: ids) { [weak self] result in
                            switch result {
                            case .success(let model):
                                self?.footerVM = model.artists
                            case .failure(let error):
                                print(error.localizedDescription)
                            }
                        }
                    }
                case .failure(let error):
                    print(error.localizedDescription)
                }
            }
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        collectionView.frame = view.bounds
    }
    
    @objc private func didTapMore() {
        guard let url = URL(string: playlist.external_urls["spotify"] ?? "") else {
            return
        }
        let activityVC = UIActivityViewController(
            activityItems: [url],
            applicationActivities: []
        )
        activityVC.popoverPresentationController?.barButtonItem = navigationItem.rightBarButtonItem
        present(activityVC, animated: true)
    }
}

extension PlayListVC: UICollectionViewDelegate, UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModels.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: RecommendedTracksCell.identifier,
                                                            for: indexPath) as? RecommendedTracksCell else {
            return UICollectionViewCell()
        }
        cell.config(with: viewModels[indexPath.row], isOwner: self.isOwner)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        if kind == UICollectionView.elementKindSectionHeader {
            guard let header = collectionView.dequeueReusableSupplementaryView(
                ofKind: kind,
                withReuseIdentifier: PlayListHeaderView.identifier,
                for: indexPath) as? PlayListHeaderView,
                  kind == UICollectionView.elementKindSectionHeader else {
                      return UICollectionReusableView()
                  }
            
            let headerVM = PlayListHeaderVM(playlistName: playlist.name,
                                            ownerName: playlist.owner.display_name,
                                            playlistDescription: playlist.description,
                                            artWorkURL: URL(string: playlist.images.first?.url ?? ""))
            header.config(with: headerVM)
            header.delegate = self
            return header
        }
        
        if kind == UICollectionView.elementKindSectionFooter {
            guard let footer = collectionView.dequeueReusableSupplementaryView(
                ofKind: kind,
                withReuseIdentifier: ArtistsCollectionView.identifier,
                for: indexPath) as? ArtistsCollectionView,
                  kind == UICollectionView.elementKindSectionFooter else {
                      return UICollectionReusableView()
            }
            footer.config(with: footerVM)
            return footer
        }
        return UICollectionReusableView()
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
        let track = tracks[indexPath.row]
        PlayBackPresenter.shared.startPlayBack(in: self, with: track)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForFooterInSection section: Int) -> CGSize {
        return CGSize(width: view.width, height: 150)
    }
}

extension PlayListVC: UICollectionViewDataSourcePrefetching {
    func collectionView(_ collectionView: UICollectionView, prefetchItemsAt indexPaths: [IndexPath]) {
        for indexPath in indexPaths {
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: RecommendedTracksCell.identifier, for: indexPath) as? RecommendedTracksCell else {
                continue
            }
            cell.config(with: viewModels[indexPath.row])
        }
    }
}

extension PlayListVC: PlayListHeaderViewDelegate {
    func playListHeaderViewDidTapPlay(_ header: PlayListHeaderView) {
        PlayBackPresenter.shared.startPlayBack(in: self, with: tracks)
    }
    
    func playListHeaderViewDidTapShuffle(_ header: PlayListHeaderView) {
        
    }
}


extension PlayListVC {
    func collectionView(_ collectionView: UICollectionView, performAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) {
        let track = tracks[indexPath.row]
        APICaller.shared.removeTrackFromPlaylist(track: track, playlist: playlist) { [weak self] success in
            DispatchQueue.main.async {
                if success {
                    self?.tracks.remove(at: indexPath.row)
                    self?.viewModels.remove(at: indexPath.row)
                    collectionView.reloadData()
                } else {
                    print("Failed to Remove Track From Playlist")
                }
            }
        }
    }
}
