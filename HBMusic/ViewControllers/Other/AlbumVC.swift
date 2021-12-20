//
//  AlbumVC.swift
//  HBMusic
//
//  Created by 徐浩博 on 2021/11/27.
//

import UIKit

class AlbumVC: UIViewController {

    private let album: Album
    
    private let collectionView: UICollectionView = {
        let layout = UICollectionViewCompositionalLayout { index, _ in
            let item = NSCollectionLayoutItem(
                layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalHeight(1.0))
            )
            
            item.contentInsets = NSDirectionalEdgeInsets(top: 2, leading: 2, bottom: 2, trailing: 2)
            
            let group = NSCollectionLayoutGroup.vertical(
                layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .absolute(60)),
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
            AlbumTracksCell.self,
            forCellWithReuseIdentifier: AlbumTracksCell.identifier
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
    
    private var viewModels: [AlbumTracksCellVM] = []
    private var tracks: [AudioTrack] = []
    
    private var footerArtistsIDs = Set<String>()
    private var footerVM: [ArtistResponce] = []
    
    init(_ album: Album) {
        self.album = album
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = album.name
        view.backgroundColor = .systemBackground
        view.addSubview(collectionView)
        
        collectionView.delegate = self
        collectionView.dataSource = self
        
        fetchData()
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .action, target: self, action: #selector(didTapAction))
    }
    
    @objc func didTapAction() {
        let actionSheet = UIAlertController(title: album.name, message: "Actions", preferredStyle: .actionSheet)
        actionSheet.addAction(UIAlertAction(title: "Save Album", style: .default, handler: { _ in
            APICaller.shared.saveAlbums(ids: self.album.id) {success in
                if success {
                    NotificationCenter.default.post(name: .kAlbumSavedNotification, object: nil)
                    HapticsManger.shared.vibrate(for: .success)
                } else {
                    print("Failed to save Album")
                    HapticsManger.shared.vibrate(for: .error)
                }
            }
        }))
        actionSheet.addAction(UIAlertAction(title: "Cancle", style: .cancel))
        present(actionSheet, animated: true)
    }
    
    private func fetchData() {
        APICaller.shared.getAlbumDetail(for: album) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let model):
                    self?.tracks = model.tracks.items
                    self?.viewModels = model.tracks.items.compactMap({ item in
                        return AlbumTracksCellVM(name: item.name,
                                                       artistName: item.artists.first?.name ?? "-")
                    })
                    self?.collectionView.reloadData()
                    for item in model.tracks.items {
                        if let id = item.artists.first?.id {
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
                    ids.removeLast()
                    DispatchQueue.global().async {
                        APICaller.shared.getSeveralArtists(ids: ids) { [weak self] result in
                            switch result {
                            case .success(let model):
                                self?.footerVM = model.artists
                                DispatchQueue.main.async {
                                    self?.collectionView.reloadData()
                                }
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
}

extension AlbumVC: UICollectionViewDelegate, UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModels.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: AlbumTracksCell.identifier,
                                                            for: indexPath) as? AlbumTracksCell else {
            return UICollectionViewCell()
        }
        cell.config(with: viewModels[indexPath.row])
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
            let headerVM = PlayListHeaderVM(playlistName: album.name,
                                            ownerName: album.artists.first?.name ?? "-",
                                            playlistDescription: album.release_date,
                                            artWorkURL: URL(string: album.images.first?.url ?? ""))
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
        var track = tracks[indexPath.row]
        track.album = self.album
        PlayBackPresenter.shared.startPlayBack(in: self, with: track)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForFooterInSection section: Int) -> CGSize {
        return CGSize(width: view.width, height: 150)
    }
}

extension AlbumVC: PlayListHeaderViewDelegate {
    func playListHeaderViewDidTapPlay(_ header: PlayListHeaderView) {
        let tracksWithAlbum: [AudioTrack] = tracks.compactMap { track in
            var track = track
            track.album = self.album
            return track
        }
        PlayBackPresenter.shared.startPlayBack(in: self, with: tracksWithAlbum)
    }
    
    func playListHeaderViewDidTapShuffle(_ header: PlayListHeaderView) {
        print("AlbumVC - shuffle")
    }
}
