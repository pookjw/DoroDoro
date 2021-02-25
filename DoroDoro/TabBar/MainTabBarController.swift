//
//  MainTabBarController.swift
//  DoroDoro
//
//  Created by Jinwoo Kim on 2/25/21.
//

import UIKit

final class MainTabBarController: UITabBarController {
    public weak var searchVC: SearchViewController? = nil
    public weak var favoritesVC: FavoritesViewController? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureViewControllers()
    }
    
    private func configureViewControllers() {
        let searchVC: SearchViewController = .init()
        let favoritesVC: FavoritesViewController = .init()
        self.searchVC = searchVC
        self.favoritesVC = favoritesVC
        
        searchVC.tabBarItem = .init(title: NSLocalizedString("TABBAR_SEARCH_VIEW_CONTROLLER_TITLE", comment: "검색"),
                                    image: UIImage(systemName: "magnifyingglass"),
                                    tag: 0)
        favoritesVC.tabBarItem = .init(title: NSLocalizedString("TABBAR_FAVORITES_VIEW_CONTROLLER_TITLE", comment: "Favorites"),
                                       image: UIImage(systemName: "star.fill"),
                                       tag: 1)
        
        setViewControllers([searchVC, favoritesVC], animated: false)
    }
}
