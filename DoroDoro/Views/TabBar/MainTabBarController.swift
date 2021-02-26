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
    public weak var settingsVC: SettingsViewController? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureViewControllers()
    }
    
    private func configureViewControllers() {
        let searchVC: SearchViewController = .init()
        let favoritesVC: FavoritesViewController = .init()
        let settingsVC: SettingsViewController = .init()
        self.searchVC = searchVC
        self.favoritesVC = favoritesVC
        self.settingsVC = settingsVC
        
        
        searchVC.tabBarItem = .init(title: Localizable.TABBAR_SEARCH_VIEW_CONTROLLER_TITLE.string,
                                    image: UIImage(systemName: "magnifyingglass"),
                                    tag: 0)
        favoritesVC.tabBarItem = .init(title: Localizable.TABBAR_FAVORITES_VIEW_CONTROLLER_TITLE.string,
                                       image: UIImage(systemName: "star.fill"),
                                       tag: 1)
        settingsVC.tabBarItem = .init(title: Localizable.TABBAR_SETTINGS_VIEW_CONTROLLER_TITLE.string,
                                       image: UIImage(systemName: "gear"),
                                       tag: 2)
        
        setViewControllers([searchVC, favoritesVC, settingsVC], animated: false)
    }
}
