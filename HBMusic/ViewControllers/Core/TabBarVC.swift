//
//  TabBarVC.swift
//  HBMusic
//
//  Created by 徐浩博 on 2021/11/17.
//

import UIKit

class TabBarVC: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        //updateTabBarAppearance()
        
        let homeVC = HomeVC()
        let searchVC = SearchVC()
        let libraryVC = LibraryVC()
        
        homeVC.title = "Browse"
        searchVC.title = "Search"
        libraryVC.title = "Library"
        
        homeVC.navigationItem.largeTitleDisplayMode = .always
        searchVC.navigationItem.largeTitleDisplayMode = .always
        libraryVC.navigationItem.largeTitleDisplayMode = .always
        
        let nav1 = UINavigationController(rootViewController: homeVC)
        let nav2 = UINavigationController(rootViewController: searchVC)
        let nav3 = UINavigationController(rootViewController: libraryVC)
        
        nav1.navigationBar.tintColor = .systemPink
        nav2.navigationBar.tintColor = .systemPink
        nav3.navigationBar.tintColor = .systemPink
        
        nav1.tabBarItem = UITabBarItem(title: "Home", image: UIImage(systemName: "house"), tag: 1)
        nav2.tabBarItem = UITabBarItem(title: "Search", image: UIImage(systemName: "magnifyingglass"), tag: 2)
        nav3.tabBarItem = UITabBarItem(title: "Library", image: UIImage(systemName: "music.note.list"), tag: 3)
        
        self.tabBar.tintColor = .systemPink
        self.tabBar.isTranslucent = true
        
        nav1.navigationBar.prefersLargeTitles = true
        nav2.navigationBar.prefersLargeTitles = true
        nav3.navigationBar.prefersLargeTitles = true
        
        setViewControllers([nav1, nav2, nav3], animated: true)
    }

}

//extension TabBarVC {
//    @available(iOS 15.0, *)
//    private func updateTabBarAppearance() {
//        let tabBarAppearance: UITabBarAppearance = UITabBarAppearance()
//        tabBarAppearance.configureWithOpaqueBackground()
//
//        let barTintColor: UIColor = .white
//        tabBarAppearance.backgroundColor = barTintColor
//
//        updateTabBarItemAppearance(appearance: tabBarAppearance.compactInlineLayoutAppearance)
//        updateTabBarItemAppearance(appearance: tabBarAppearance.inlineLayoutAppearance)
//        updateTabBarItemAppearance(appearance: tabBarAppearance.stackedLayoutAppearance)
//
//        self.tabBar.standardAppearance = tabBarAppearance
//        self.tabBar.scrollEdgeAppearance = tabBarAppearance
//    }
//
//    @available(iOS 13.0, *)
//    private func updateTabBarItemAppearance(appearance: UITabBarItemAppearance) {
//        let tintColor: UIColor = .systemPink
//        let unselectedItemTintColor: UIColor = .systemGray
//
//        appearance.selected.iconColor = tintColor
//        appearance.normal.iconColor = unselectedItemTintColor
//    }
//}
