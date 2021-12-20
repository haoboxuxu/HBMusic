//
//  CategoryVC.swift
//  HBMusic
//
//  Created by 徐浩博 on 2021/11/30.
//

import UIKit

class CategoryVC: UIViewController {
    
    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewCompositionalLayout { _, _ in
            let item = NSCollectionLayoutItem(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1),
                                                                                 heightDimension: .fractionalHeight(1)))
            item.contentInsets = NSDirectionalEdgeInsets(top: 5, leading: 5, bottom: 5, trailing: 5)
            
            let group = NSCollectionLayoutGroup.horizontal(
                layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .absolute(250)),
                subitem: item,
                count: 2
            )
            return NSCollectionLayoutSection(group: group)
        }
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.register(CategoryCollectionViewCell.self, forCellWithReuseIdentifier: CategoryCollectionViewCell.identifier)
        collectionView.backgroundColor = .systemBackground
        collectionView.register(PlaylistCell.self, forCellWithReuseIdentifier: PlaylistCell.identifier)
        return collectionView
    }()
    
    init(category: MusicCategory) {
        self.category = category
        super.init(nibName: nil, bundle: nil)
    }
    
    private var playlists: [Playlist] = []
    
    private var category: MusicCategory
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = category.name
        view.addSubview(collectionView)
        collectionView.delegate = self
        collectionView.dataSource = self
        
        APICaller.shared.getCatagoryPlayList(category: category) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let model):
                    self?.playlists = model
                    self?.collectionView.reloadData()
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
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}

extension CategoryVC: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return playlists.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: PlaylistCell.identifier, for: indexPath) as? PlaylistCell else {
            return UICollectionViewCell()
        }
        cell.config(with: FeaturedPlaylistCellVM(name: playlists[indexPath.row].name,
                                                 artWorkURL: URL(string: playlists[indexPath.row].images.first?.url ?? ""),
                                                 creatorName: playlists[indexPath.row].owner.display_name))
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
        let playlist = playlists[indexPath.row]
        let playlistVC = PlayListVC(playlist)
        playlistVC.navigationItem.largeTitleDisplayMode = .never
        navigationController?.pushViewController(playlistVC, animated: true)
    }
}
