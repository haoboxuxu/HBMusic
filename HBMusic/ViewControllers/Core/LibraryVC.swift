//
//  LibraryVC.swift
//  HBMusic
//
//  Created by 徐浩博 on 2021/11/17.
//

import UIKit

class LibraryVC: UIViewController {
    
    private let libraryPlayListVC = LibraryPlayListVC()
    private let libraryAlbumVC = LibraryAlbumVC()
    
    private let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.isPagingEnabled = true
        return scrollView
    }()
    
    private let toggleView = LibraryToggleView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        
        view.addSubview(scrollView)
        scrollView.contentSize = CGSize(width: view.width*2, height: scrollView.height)
        scrollView.delegate = self
        addChildrenVC()
        
        view.addSubview(toggleView)
        toggleView.delegate = self
        
        updateBarButtons()
    }
    
    private func updateBarButtons() {
        switch toggleView.indicatorState {
        case .playlist:
            navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(didTapAdd))
        case .album:
            navigationItem.rightBarButtonItem = nil
        }
    }
    
    @objc func didTapAdd() {
        libraryPlayListVC.presentCreatePlayListVC()
    }
    
    private func addChildrenVC() {
        addChild(libraryPlayListVC)
        scrollView.addSubview(libraryPlayListVC.view)
        libraryPlayListVC.view.frame = CGRect(x: 0, y: 0, width: scrollView.width, height: scrollView.height)
        libraryPlayListVC.didMove(toParent: self)
        
        addChild(libraryAlbumVC)
        scrollView.addSubview(libraryAlbumVC.view)
        libraryAlbumVC.view.frame = CGRect(x: view.width, y: 0, width: scrollView.width, height: scrollView.height)
        libraryAlbumVC.didMove(toParent: self)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        scrollView.frame = CGRect(x: 0,
                                  y: view.safeAreaInsets.top+55,
                                  width: view.width,
                                  height: view.height-view.safeAreaInsets.top-view.safeAreaInsets.bottom-55)
        toggleView.frame = CGRect(x: 0, y: view.safeAreaInsets.top, width: 200, height: 55)
    }
}

extension LibraryVC: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView.contentOffset.x >= (scrollView.width-100) {
            toggleView.updateIndicatorView(for: .album)
        } else {
            toggleView.updateIndicatorView(for: .playlist)
        }
        updateBarButtons()
    }
}

extension LibraryVC: LibraryToggleViewDelegate {
    func libraryToggleViewDidTapPlaylist(_ libraryToggleView: LibraryToggleView) {
        scrollView.setContentOffset(CGPoint(x: 0, y: 0), animated: true)
        updateBarButtons()
    }
    
    func libraryToggleViewDidTapAlbumButton(_ libraryToggleView: LibraryToggleView) {
        scrollView.setContentOffset(CGPoint(x: scrollView.width, y: 0), animated: true)
        updateBarButtons()
    }
}
