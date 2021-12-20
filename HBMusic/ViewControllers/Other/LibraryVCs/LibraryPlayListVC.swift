//
//  LibraryPlayListVC.swift
//  HBMusic
//
//  Created by 徐浩博 on 2021/12/6.
//

import UIKit

class LibraryPlayListVC: UIViewController {
    
    var playlists: [Playlist] = []
    
    public var selectionHandler: ((Playlist) -> Void)?
    
    private let tableView: UITableView = {
        let tableView = UITableView()
        tableView.register(SearchResultSubtitleCell.self, forCellReuseIdentifier: SearchResultSubtitleCell.identifier)
        tableView.isHidden = true
        return tableView
    }()
    
    let noPlayListsView: ActionLabelView = {
        let noPlayListsView = ActionLabelView()
        noPlayListsView.config(ActionLabelVM(text: "You don't have any playlist", actionTitle: "Create"))
        return noPlayListsView
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .systemBackground
        view.addSubview(noPlayListsView)
        noPlayListsView.delegate = self
        
        view.addSubview(tableView)
        tableView.delegate = self
        tableView.dataSource = self
        
        fetchPlaylists()
        
        if selectionHandler != nil {
            navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .close, target: self, action: #selector(didTapClose))
        }
    }
    
    @objc private func didTapClose() {
        dismiss(animated: true)
    }
    
    private func fetchPlaylists() {
        APICaller.shared.getCurrentUserPlaylists { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let playlists):
                    self?.playlists = playlists
                    self?.reloadUI()
                case .failure(let error):
                    print(error.localizedDescription)
                }
            }
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        noPlayListsView.frame = CGRect(x: 0, y: 0, width: view.width-100, height: 100)
        noPlayListsView.center = view.center
        tableView.frame = view.bounds
    }
    
    private func reloadUI() {
        if playlists.isEmpty {
            noPlayListsView.isHidden = false
            tableView.isHidden = true
        } else {
            noPlayListsView.isHidden = true
            tableView.isHidden = false
            tableView.reloadData()
        }
    }

}

extension LibraryPlayListVC: ActionLabelViewDelegate {
    func actionLabelViewDidTapButton(_ actionLabelView: ActionLabelView) {
        presentCreatePlayListVC()
    }
    
    func presentCreatePlayListVC() {
        let createPlayListVC = CreatePlayListVC()
        createPlayListVC.delegate = self
        self.present(UINavigationController(rootViewController: createPlayListVC), animated: true)
    }
}

extension LibraryPlayListVC: CreatePlayListVCDelegate {
    func createPlayListVCDelegateDidTapDone(_ createPlayListVC: CreatePlayListVC, _ createPlayListVM: CreatePlayListVM) {
        createPlayListVC.dismiss(animated: true)
        let name = createPlayListVM.name.trimmingCharacters(in: .whitespaces)
        
        if !name.isEmpty {
            APICaller.shared.createPlaylist(name: name) { [weak self] success in
                if success {
                    HapticsManger.shared.vibrate(for: .success)
                    self?.fetchPlaylists()
                } else {
                    HapticsManger.shared.vibrate(for: .error)
                    print("failed to create playlist")
                }
            }
        }
        
    }
}


extension LibraryPlayListVC: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        playlists.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: SearchResultSubtitleCell.identifier) as! SearchResultSubtitleCell
        let playlist = playlists[indexPath.row]
        cell.config(with: SearchResultSubtitleCellVM(title: playlist.name,
                                                     subtitle: playlist.owner.display_name,
                                                     imageURL: URL(string: playlist.images.first?.url ?? "")))
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        HapticsManger.shared.vibrateForSelestion()
        let playlist = playlists[indexPath.row]
        
        guard selectionHandler == nil else {
            selectionHandler?(playlist)
            dismiss(animated: true)
            return
        }
        
        let playListVC = PlayListVC(playlist)
        playListVC.isOwner = true
        playListVC.navigationItem.largeTitleDisplayMode = .never
        navigationController?.pushViewController(playListVC, animated: true)
    }
}
