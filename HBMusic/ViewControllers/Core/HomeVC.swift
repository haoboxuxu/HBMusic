//
//  ViewController.swift
//  HBMusic
//
//  Created by 徐浩博 on 2021/11/17.
//

import UIKit

enum BrowseSectionType {
    case newReleases(viewModel: [NewReleasesCellVM])
    case featuredPlaylist(viewModel: [FeaturedPlaylistCellVM])
    case recommendedTracks(viewModel: [RecommendedTracksCellVM])
    
    var title: String {
        switch self {
        case .newReleases:
            return "New Releases"
        case .featuredPlaylist:
            return "Featured Playlist"
        case .recommendedTracks:
            return "Recommended Tracks"
        }
    }
}

class HomeVC: UIViewController {
    
    private var newAlbums: [Album] = []
    private var playlists: [Playlist] = []
    private var tracks: [AudioTrack] = []
    
    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewCompositionalLayout { sectionIndex, _ in
            Self.createSectionLayout(sectionIndex: sectionIndex)
        }
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        return collectionView
    }()
    
    private var spinner: UIActivityIndicatorView = {
        let spinner = UIActivityIndicatorView()
        spinner.color = .label
        spinner.hidesWhenStopped = true
        return spinner
    }()
    
    private var sections = [BrowseSectionType]()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            image: UIImage(systemName: "gear.circle"),
            style: .plain,
            target: self,
            action: #selector(didTappedProfile)
        )
        configCollectionView()
        view.addSubview(spinner)
        fetchData()
        addForceTouchGesture()
    }
    
    private func addForceTouchGesture() {
        let gesture = UILongPressGestureRecognizer(target: self, action: #selector(didForceTouch(_:)))
        collectionView.isUserInteractionEnabled = true
        collectionView.addGestureRecognizer(gesture)
    }
    
    @objc private func didForceTouch(_ gesture: UILongPressGestureRecognizer) {
        guard gesture.state == .began else {
            return
        }
        
        let touchPoint = gesture.location(in: collectionView)
        guard let indexPath = collectionView.indexPathForItem(at: touchPoint), indexPath.section == 2 else {
            return
        }
        
        let track = tracks[indexPath.row]
        
        let actionSheet = UIAlertController(title: track.name, message: "Add to personal playlist", preferredStyle: .actionSheet)
        actionSheet.addAction(UIAlertAction(title: "Cacel", style: .cancel))
        actionSheet.addAction(UIAlertAction(title: "Add to Playlist", style: .default, handler: { [weak self] _ in
            DispatchQueue.main.async {
                let libraryPlayListVC = LibraryPlayListVC()
                libraryPlayListVC.selectionHandler = { playlist in
                    APICaller.shared.addTrackToPlaylist(track: track, playlist: playlist) { success in
                        
                    }
                }
                libraryPlayListVC.title = "Select Playlist"
                self?.present(UINavigationController(rootViewController: libraryPlayListVC), animated: true)
            }
        }))
        
        present(actionSheet, animated: true)
    }
    
    func configCollectionView() {
        view.addSubview(collectionView)
        collectionView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "cell")
        
        collectionView.register(NewReleasesCell.self, forCellWithReuseIdentifier: NewReleasesCell.identifier)
        collectionView.register(PlaylistCell.self, forCellWithReuseIdentifier: PlaylistCell.identifier)
        collectionView.register(RecommendedTracksCell.self, forCellWithReuseIdentifier: RecommendedTracksCell.identifier)
        collectionView.register(TitleHeaderCRView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: TitleHeaderCRView.identifier)
        
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.backgroundColor = .systemBackground
        collectionView.frame = view.bounds
    }
    
    
    private func fetchData() {
        let group = DispatchGroup()
        group.enter()
        group.enter()
        group.enter()
        
        var newReleases: NewReleasesResponce?
        var featuredPlaylists: FeaturedPlaylistsResponce?
        var recommendations: RecommendationsResponce?
        
        // New Releases
        APICaller.shared.getNewReleases { result in
            defer {
                group.leave()
            }
            switch result {
            case .success(let model):
                newReleases = model
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
        
        // Featured Playlist
        APICaller.shared.getFeaturedPlaylists { result in
            defer {
                group.leave()
            }
            switch result {
            case .success(let model):
                featuredPlaylists = model
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
        
        // Recommended Tracks
        APICaller.shared.getRecommendedGenres { result in
            switch result {
            case .success(let model):
                let genres = model.genres
                var seeds = Set<String>()
                while (seeds.count < 5) {
                    if let randElem = genres.randomElement() {
                        seeds.insert(randElem)
                    }
                }
                APICaller.shared.getRecommendations(genres: seeds) { recommendedResult in
                    defer {
                        group.leave()
                    }
                    switch recommendedResult {
                    case .success(let model):
                        recommendations = model
                    case .failure(let error):
                        print(error.localizedDescription)
                    }
                }
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
        
        group.notify(queue: .main) {
            guard let newAlbums = newReleases?.albums.items, let playlists = featuredPlaylists?.playlists.items, let tracks = recommendations?.tracks else {
                return
            }
            self.configViewModels(newAlbums, playlists, tracks)
        }
        
        
    }
    
    private func configViewModels(_ newAlbums: [Album], _ playlists: [Playlist], _ tracks: [AudioTrack]) {
        self.newAlbums = newAlbums
        self.playlists = playlists
        self.tracks = tracks
        
        sections.append(.newReleases(viewModel: newAlbums.compactMap({ album in
            return NewReleasesCellVM(name: album.name,
                                     artWorkURL: URL(string: album.images.first?.url ?? ""),
                                     numberOfTracks: album.total_tracks,
                                     artistName: album.artists.first?.name ?? "-")
        })))
        sections.append(.featuredPlaylist(viewModel: playlists.compactMap({ playlist in
            return FeaturedPlaylistCellVM(name: playlist.name,
                                          artWorkURL: URL(string: playlist.images.first?.url ?? ""),
                                          creatorName: playlist.owner.display_name)
        })))
        sections.append(.recommendedTracks(viewModel: tracks.compactMap({ track in
            return RecommendedTracksCellVM(name: track.name,
                                           artistName: track.artists.first?.name ?? "-",
                                           artWorkURL: URL(string: track.album?.images.first?.url ?? ""))
        })))
        collectionView.reloadData()
    }

    @objc func didTappedProfile() {
        let settingVC = SettingVC()
        settingVC.navigationItem.largeTitleDisplayMode = .never
        navigationController?.pushViewController(settingVC, animated: true)
    }
}

extension HomeVC: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let type = sections[section]
        switch type {
        case .newReleases(let viewModel):
            return viewModel.count
        case .featuredPlaylist(let viewModel):
            return viewModel.count
        case .recommendedTracks(let viewModel):
            return viewModel.count
        }
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return sections.count
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
        HapticsManger.shared.vibrateForSelestion()
        let section = sections[indexPath.section]
        switch section {
        case .featuredPlaylist:
            let playlist = playlists[indexPath.row]
            let playlistVC = PlayListVC(playlist)
            playlistVC.navigationItem.largeTitleDisplayMode = .never
            navigationController?.pushViewController(playlistVC, animated: true)
            break
        case .newReleases:
            let album = newAlbums[indexPath.row]
            let albumVC = AlbumVC(album)
            albumVC.navigationItem.largeTitleDisplayMode = .never
            navigationController?.pushViewController(albumVC, animated: true)
        case .recommendedTracks:
            let track = tracks[indexPath.row]
            print("recommendedTracks play")
            PlayBackPresenter.shared.startPlayBack(in: self, with: track)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let type = sections[indexPath.section]
        switch type {
        case .newReleases(let viewModels):
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: NewReleasesCell.identifier,
                                                                for: indexPath) as? NewReleasesCell else {
                return UICollectionViewCell()
            }
            cell.config(with: viewModels[indexPath.row])
            return cell
        case .featuredPlaylist(let viewModels):
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: PlaylistCell.identifier,
                                                                for: indexPath) as? PlaylistCell else {
                return UICollectionViewCell()
            }
            cell.config(with: viewModels[indexPath.row])
            return cell
        case .recommendedTracks(let viewModels):
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: RecommendedTracksCell.identifier,
                                                                for: indexPath) as? RecommendedTracksCell
            else {
                return UICollectionViewCell()
            }
            cell.config(with: viewModels[indexPath.row])
            return cell
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        guard let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind,
                                                                           withReuseIdentifier: TitleHeaderCRView.identifier,
                                                                           for: indexPath) as? TitleHeaderCRView,
                kind == UICollectionView.elementKindSectionHeader else {
            return UICollectionReusableView()
        }
        header.config(with: sections[indexPath.section].title)
        return header
    }
    
    static func createSectionLayout(sectionIndex: Int) -> NSCollectionLayoutSection {
        let supplementaryViews = [
            NSCollectionLayoutBoundarySupplementaryItem(
                layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1),
                                                   heightDimension: .absolute(60)),
                elementKind: UICollectionView.elementKindSectionHeader,
                alignment: .top
            )
        ]
        switch sectionIndex {
        case 0:
            let item = NSCollectionLayoutItem(
                layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalHeight(1.0))
            )
            
            item.contentInsets = NSDirectionalEdgeInsets(top: 2, leading: 2, bottom: 2, trailing: 2)
            
            let verticalGroup = NSCollectionLayoutGroup.vertical(
                layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .absolute(390)),
                subitem: item,
                count: 3
            )
            
            let horizontalGroup = NSCollectionLayoutGroup.horizontal(
                layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.9), heightDimension: .absolute(390)),
                subitem: verticalGroup,
                count: 1
            )
            
            let section = NSCollectionLayoutSection(group: horizontalGroup)
            section.orthogonalScrollingBehavior = .groupPaging
            section.boundarySupplementaryItems = supplementaryViews
            return section
        case 1:
            let item = NSCollectionLayoutItem(
                layoutSize: NSCollectionLayoutSize(widthDimension: .absolute(200), heightDimension: .absolute(200))
            )
            
            item.contentInsets = NSDirectionalEdgeInsets(top: 2, leading: 2, bottom: 2, trailing: 2)
            
            let verticalGroup = NSCollectionLayoutGroup.vertical(
                layoutSize: NSCollectionLayoutSize(widthDimension: .absolute(200), heightDimension: .absolute(400)),
                subitem: item,
                count: 2
            )
            
            let horizontalGroup = NSCollectionLayoutGroup.horizontal(
                layoutSize: NSCollectionLayoutSize(widthDimension: .absolute(200), heightDimension: .absolute(400)),
                subitem: verticalGroup,
                count: 1
            )
            
            let section = NSCollectionLayoutSection(group: horizontalGroup)
            section.orthogonalScrollingBehavior = .continuous
            section.boundarySupplementaryItems = supplementaryViews
            return section
        case 2:
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
            section.boundarySupplementaryItems = supplementaryViews
            return section
        default:
            let item = NSCollectionLayoutItem(
                layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalHeight(1.0))
            )
            
            item.contentInsets = NSDirectionalEdgeInsets(top: 2, leading: 2, bottom: 2, trailing: 2)
            
            let group = NSCollectionLayoutGroup.horizontal(
                layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.9), heightDimension: .absolute(390)),
                subitem: item,
                count: 1
            )
            let section = NSCollectionLayoutSection(group: group)
            section.boundarySupplementaryItems = supplementaryViews
            return section
        }
    }
}
