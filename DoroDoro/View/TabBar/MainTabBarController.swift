//
//  MainTabBarController.swift
//  DoroDoro
//
//  Created by Jinwoo Kim on 2/25/21.
//

import UIKit

final internal class MainTabBarController: UITabBarController {
    internal weak var searchVC: SearchViewController? = nil
    internal weak var searchNVC: UINavigationController? = nil
    internal weak var bookmarksVC: BookmarksViewController? = nil
    internal weak var bookmarksNVC: UINavigationController? = nil
    internal weak var settingsVC: SettingsViewController? = nil
    internal weak var settingsNVC: UINavigationController? = nil
    
    override internal func viewDidLoad() {
        super.viewDidLoad()
        configureViewControllers()
    }
    
    override internal func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    private func configureViewControllers() {
        let searchVC: SearchViewController = .init()
        let searchNVC: UINavigationController = .init(rootViewController: searchVC)
        let bookmarksVC: BookmarksViewController = .init()
        let bookmarksNVC: UINavigationController = .init(rootViewController: bookmarksVC)
        let settingsVC: SettingsViewController = .init()
        let settingsNVC: UINavigationController = .init(rootViewController: settingsVC)
        
        self.searchVC = searchVC
        self.searchNVC = searchNVC
        self.bookmarksVC = bookmarksVC
        self.bookmarksNVC = bookmarksNVC
        self.settingsVC = settingsVC
        self.settingsNVC = settingsNVC
        
        searchVC.loadViewIfNeeded()
        searchNVC.loadViewIfNeeded()
        bookmarksVC.loadViewIfNeeded()
        bookmarksNVC.loadViewIfNeeded()
        settingsVC.loadViewIfNeeded()
        settingsNVC.loadViewIfNeeded()
        
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
        
        setViewControllers([searchNVC, bookmarksNVC, settingsNVC], animated: false)
    }
}
