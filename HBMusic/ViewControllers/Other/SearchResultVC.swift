//
//  SearchResultVC.swift
//  HBMusic
//
//  Created by 徐浩博 on 2021/11/17.
//

import UIKit
import SafariServices

struct SearchSection {
    let title: String
    let results: [SearchResult]
}

protocol SearchResultDelegate: AnyObject {
    func didTapSearchResult(_ searchResult: SearchResult)
}

class SearchResultVC: UIViewController {
    
    var sections: [SearchSection] = []
    
    weak var delegate: SearchResultDelegate?
    
    private let tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .grouped)
        tableView.register(SearchResultDefaultCell.self, forCellReuseIdentifier: SearchResultDefaultCell.identifier)
        tableView.register(SearchResultSubtitleCell.self, forCellReuseIdentifier: SearchResultSubtitleCell.identifier)
        tableView.isHidden = true
        return tableView
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        view.addSubview(tableView)
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        tableView.frame = view.bounds
    }

    func update(with results: [SearchResult]) {
        let artist = results.filter {
            switch $0 {
            case .artist:
                return true
            default:
                return false
            }
        }
        let album = results.filter {
            switch $0 {
            case .album:
                return true
            default:
                return false
            }
        }
        let playlist = results.filter {
            switch $0 {
            case .playlist:
                return true
            default:
                return false
            }
        }
        let track = results.filter {
            switch $0 {
            case .track:
                return true
            default:
                return false
            }
        }
        sections = [
            SearchSection(title: "Artists", results: artist),
            SearchSection(title: "Playlists", results: playlist),
            SearchSection(title: "Album", results: album),
            SearchSection(title: "Tracks", results: track)
        ]
        tableView.reloadData()
        if !self.sections.isEmpty {
            tableView.isHidden = false
        }
    }
}

extension SearchResultVC: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return sections.count
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return sections[section].title
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sections[section].results.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let result = sections[indexPath.section].results[indexPath.row]
        switch result {
        case .artist(let artist):
            guard let cell = tableView.dequeueReusableCell(withIdentifier: SearchResultDefaultCell.identifier, for: indexPath) as? SearchResultDefaultCell else {
                return UITableViewCell()
            }
            cell.config(with: SearchResultDefaultCellVM(title: artist.name,
                                                        imageURL: URL(string: artist.images?.first?.url ?? "")))
            return cell
        case .album(let album):
            guard let cell = tableView.dequeueReusableCell(withIdentifier: SearchResultSubtitleCell.identifier, for: indexPath) as? SearchResultSubtitleCell else {
                return UITableViewCell()
            }
            cell.config(with: SearchResultSubtitleCellVM(title: album.name,
                                                         subtitle: album.artists.first?.name ?? "",
                                                         imageURL: URL(string: album.images.first?.url ?? "")))
            return cell
        case .playlist(let playlist):
            guard let cell = tableView.dequeueReusableCell(withIdentifier: SearchResultSubtitleCell.identifier, for: indexPath) as? SearchResultSubtitleCell else {
                return UITableViewCell()
            }
            cell.config(with: SearchResultSubtitleCellVM(title: playlist.name,
                                                         subtitle: playlist.owner.display_name,
                                                         imageURL: URL(string: playlist.images.first?.url ?? "")))
            return cell
        case .track(let track):
            guard let cell = tableView.dequeueReusableCell(withIdentifier: SearchResultSubtitleCell.identifier, for: indexPath) as? SearchResultSubtitleCell else {
                return UITableViewCell()
            }
            cell.config(with: SearchResultSubtitleCellVM(title: track.name,
                                                         subtitle: track.artists.first?.name ?? "",
                                                         imageURL: URL(string: track.album?.images.first?.url ?? "")))
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let result = sections[indexPath.section].results[indexPath.row]
        delegate?.didTapSearchResult(result)
    }
}
