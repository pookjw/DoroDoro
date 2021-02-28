//
//  MainTabBarController.swift
//  DoroDoro
//
//  Created by Jinwoo Kim on 2/25/21.
//

import UIKit

final class MainTabBarController: UITabBarController {
    public weak var searchVC: SearchViewController? = nil
    public weak var bookmarkVC: BookmarkViewController? = nil
    public weak var settingsVC: SettingsViewController? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureViewControllers()
    }
    
    private func configureViewControllers() {
        let searchVC: SearchViewController = .init()
        let bookmarkVC: BookmarkViewController = .init()
        let settingsVC: SettingsViewController = .init()
        self.searchVC = searchVC
        self.bookmarkVC = bookmarkVC
        self.settingsVC = settingsVC
        
        let searchNVC: UINavigationController = .init(rootViewController: searchVC)
        
        searchVC.tabBarItem = .init(title: Localizable.TABBAR_SEARCH_VIEW_CONTROLLER_TITLE.string,
                                    image: UIImage(systemName: "magnifyingglass"),
                                    tag: 0)
        bookmarkVC.tabBarItem = .init(title: Localizable.TABBAR_BOOKMARK_VIEW_CONTROLLER_TITLE.string,
                                       image: UIImage(systemName: "bookmark"),
                                       tag: 1)
        settingsVC.tabBarItem = .init(title: Localizable.TABBAR_SETTINGS_VIEW_CONTROLLER_TITLE.string,
                                       image: UIImage(systemName: "gearshape"),
                                       tag: 2)
        
        setViewControllers([searchNVC, bookmarkVC, settingsVC], animated: false)
    }
}
