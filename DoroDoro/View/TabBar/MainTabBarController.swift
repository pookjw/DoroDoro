//
//  MainTabBarController.swift
//  DoroDoro
//
//  Created by Jinwoo Kim on 2/25/21.
//

import UIKit

final internal class MainTabBarController: UITabBarController {
    internal weak var searchVC: SearchViewController? = nil
    internal weak var bookmarksVC: BookmarksViewController? = nil
    internal weak var settingsVC: SettingsViewController? = nil
    
    override internal func viewDidLoad() {
        super.viewDidLoad()
        configureViewControllers()
    }
    
    private func configureViewControllers() {
        let searchVC: SearchViewController = .init()
        let bookmarksVC: BookmarksViewController = .init()
        let settingsVC: SettingsViewController = .init()
        self.searchVC = searchVC
        self.bookmarksVC = bookmarksVC
        self.settingsVC = settingsVC
        
        let searchNVC: UINavigationController = .init(rootViewController: searchVC)
        
        searchVC.tabBarItem = .init(title: Localizable.TABBAR_SEARCH_VIEW_CONTROLLER_TITLE.string,
                                    image: UIImage(systemName: "magnifyingglass"),
                                    tag: 0)
        
        bookmarksVC.tabBarItem = .init(title: Localizable.TABBAR_BOOKMARKS_VIEW_CONTROLLER_TITLE.string,
                                       image: UIImage(systemName: "bookmark"),
                                       tag: 1)
        bookmarksVC.tabBarItem.selectedImage = UIImage(systemName: "bookmark.fill")
        
        settingsVC.tabBarItem = .init(title: Localizable.TABBAR_SETTINGS_VIEW_CONTROLLER_TITLE.string,
                                       image: UIImage(systemName: "gearshape"),
                                       tag: 2)
        settingsVC.tabBarItem.selectedImage = UIImage(systemName: "gearshape.fill")
        
        setViewControllers([searchNVC, bookmarksVC, settingsVC], animated: false)
    }
}
