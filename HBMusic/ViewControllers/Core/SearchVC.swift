//
//  SearchVC.swift
//  HBMusic
//
//  Created by 徐浩博 on 2021/11/17.
//

import UIKit
import SafariServices

class SearchVC: UIViewController {
    
    let searchResultVC = SearchResultVC()
    
    lazy var searchController: UISearchController = {
        let searchController = UISearchController(searchResultsController: searchResultVC)
        searchController.searchBar.placeholder = "Artists, Songs, Albums and more"
        searchController.searchBar.searchBarStyle = .minimal
        searchController.definesPresentationContext = true
        return searchController
    }()
    
    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewCompositionalLayout { _, _ in
            let item = NSCollectionLayoutItem(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1),
                                                                                 heightDimension: .fractionalHeight(1)))
            item.contentInsets = NSDirectionalEdgeInsets(top: 5, leading: 5, bottom: 5, trailing: 5)
            
            let group = NSCollectionLayoutGroup.horizontal(
                layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1),heightDimension: .absolute(150)),
                subitem: item,
                count: 2
            )
            return NSCollectionLayoutSection(group: group)
        }
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.register(CategoryCollectionViewCell.self, forCellWithReuseIdentifier: CategoryCollectionViewCell.identifier)
        return collectionView
    }()
    
    private var categories: [MusicCategory] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        searchController.searchResultsUpdater = self
        searchController.searchBar.delegate = self
        navigationItem.searchController = searchController
        
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.backgroundColor = .systemBackground
        view.addSubview(collectionView)
        
        searchResultVC.delegate = self
        
        APICaller.shared.getSeveralCatagories { [weak self] results in
            DispatchQueue.main.async {
                switch results {
                case .success(let model):
                    self?.categories = model
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
}

extension SearchVC: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        categories.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CategoryCollectionViewCell.identifier, for: indexPath) as? CategoryCollectionViewCell else {
            return UICollectionViewCell()
        }
        cell.config(with: CategoryCollectionVM(title: categories[indexPath.row].name,
                                               artworkURL: URL(string: categories[indexPath.row].icons.first?.url ?? "")))
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
        HapticsManger.shared.vibrateForSelestion()
        let categoryVC = CategoryVC(category: categories[indexPath.row])
        categoryVC.navigationItem.largeTitleDisplayMode = .never
        navigationController?.pushViewController(categoryVC, animated: true)
    }
}

extension SearchVC: SearchResultDelegate {
    func didTapSearchResult(_ searchResult: SearchResult) {
        switch searchResult {
        case .artist(let artist):
            guard let urlStr = artist.external_urls["spotify"], let url = URL(string: urlStr) else {
                return
            }
            let sfVC = SFSafariViewController(url: url)
            present(sfVC, animated: true)
        case .album(let album):
            let albumVC = AlbumVC(album)
            albumVC.navigationItem.largeTitleDisplayMode = .never
            navigationController?.pushViewController(albumVC, animated: true)
        case .playlist(let playlist):
            let playlistVC = PlayListVC(playlist)
            playlistVC.navigationItem.largeTitleDisplayMode = .never
            navigationController?.pushViewController(playlistVC, animated: true)
        case .track(let track):
            PlayBackPresenter.shared.startPlayBack(in: self, with: track)
        }
    }
}

extension SearchVC: UISearchResultsUpdating, UISearchBarDelegate {
    func updateSearchResults(for searchController: UISearchController) {
        
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        guard let queryText = searchBar.text,
                !queryText.trimmingCharacters(in: .whitespaces).isEmpty,
                let searchResultsView = searchController.searchResultsController else {
            return
        }
        APICaller.shared.search(for: queryText) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let model):
                    self?.searchResultVC.update(with: model)
                case .failure(let error):
                    print(error.localizedDescription)
                }
            }
        }
    }
    
}
