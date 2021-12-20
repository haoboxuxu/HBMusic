//
//  LibraryAlbumVC.swift
//  HBMusic
//
//  Created by 徐浩博 on 2021/12/6.
//

import UIKit

class LibraryAlbumVC: UIViewController {
    
    var albums: [Album] = []
    
    private let tableView: UITableView = {
        let tableView = UITableView()
        tableView.register(SearchResultSubtitleCell.self, forCellReuseIdentifier: SearchResultSubtitleCell.identifier)
        tableView.isHidden = true
        return tableView
    }()
    
    let noAlbumsView: ActionLabelView = {
        let noPlayListsView = ActionLabelView()
        noPlayListsView.config(ActionLabelVM(text: "You don't have save any album", actionTitle: "Browse"))
        return noPlayListsView
    }()
    
    var obserber: NSObjectProtocol?

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .systemBackground
        view.addSubview(noAlbumsView)
        noAlbumsView.delegate = self
        
        view.addSubview(tableView)
        tableView.delegate = self
        tableView.dataSource = self
        
        fetchAlbums()
        
        obserber = NotificationCenter.default.addObserver(forName: .kAlbumSavedNotification, object: nil, queue: .main, using: { [weak self] _ in
            self?.fetchAlbums()
        })
    }
    
    @objc private func didTapClose() {
        dismiss(animated: true)
    }
    
    private func fetchAlbums() {
        albums.removeAll()
        APICaller.shared.getSavedAlbums { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let albums):
                    self?.albums = albums
                    self?.reloadUI()
                case .failure(let error):
                    print(error.localizedDescription)
                }
            }
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        noAlbumsView.frame = CGRect(x: 50, y: (view.height-100)/2, width: view.width-100, height: 100)
        tableView.frame = view.bounds
    }
    
    private func reloadUI() {
        if albums.isEmpty {
            noAlbumsView.isHidden = false
            tableView.isHidden = true
        } else {
            noAlbumsView.isHidden = true
            tableView.isHidden = false
            tableView.reloadData()
        }
    }

}

extension LibraryAlbumVC: ActionLabelViewDelegate {
    func actionLabelViewDidTapButton(_ actionLabelView: ActionLabelView) {
        tabBarController?.selectedIndex = 0
    }
}


extension LibraryAlbumVC: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        albums.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: SearchResultSubtitleCell.identifier) as! SearchResultSubtitleCell
        let album = albums[indexPath.row]
        cell.config(with: SearchResultSubtitleCellVM(title: album.name,
                                                     subtitle: album.artists.first?.name ?? "-",
                                                     imageURL: URL(string: album.images.first?.url ?? "")))
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        HapticsManger.shared.vibrateForSelestion()
        let album = albums[indexPath.row]
        
        let albumAV = AlbumVC(album)
        albumAV.navigationItem.largeTitleDisplayMode = .never
        navigationController?.pushViewController(albumAV, animated: true)
    }
}
