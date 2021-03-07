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
    
    internal var splitVCDelegate: DetailedNVCSplitViewControllerDelegate = .init()
    
    override internal func viewDidLoad() {
        super.viewDidLoad()
        configureViewControllers()
    }
    
    override internal func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    private func configureViewControllers() {
        let searchVC: SearchViewController = .init()
        let searchPrimaryNVC: UINavigationController = .init(rootViewController: searchVC)
        let searchSecondaryNVC: UINavigationController = .init()
        let searchSplitVC: UISplitViewController = .init()
        let bookmarksVC: BookmarksViewController = .init()
        let bookmarksPrimaryNVC: UINavigationController = .init(rootViewController: bookmarksVC)
        let bookmarksSecondaryNVC: UINavigationController = .init()
        let bookmarksSplitVC: UISplitViewController = .init()
        let settingsVC: SettingsViewController = .init()
        let settingsNVC: UINavigationController = .init(rootViewController: settingsVC)
        
        self.searchVC = searchVC
        self.bookmarksVC = bookmarksVC
        self.settingsVC = settingsVC
        
        searchVC.loadViewIfNeeded()
        searchPrimaryNVC.loadViewIfNeeded()
        bookmarksVC.loadViewIfNeeded()
        bookmarksPrimaryNVC.loadViewIfNeeded()
        settingsVC.loadViewIfNeeded()
        settingsNVC.loadViewIfNeeded()
        
        searchSplitVC.viewControllers = [searchPrimaryNVC, searchSecondaryNVC]
        searchSplitVC.preferredDisplayMode = .oneBesideSecondary
        searchSplitVC.delegate = splitVCDelegate
        searchSplitVC.loadViewIfNeeded()
        bookmarksSplitVC.viewControllers = [bookmarksPrimaryNVC, bookmarksSecondaryNVC]
        bookmarksSplitVC.preferredDisplayMode = .oneBesideSecondary
        bookmarksSplitVC.delegate = splitVCDelegate
        bookmarksSplitVC.loadViewIfNeeded()
        
        searchSplitVC.tabBarItem = .init(title: Localizable.SEARCH.string,
                                    image: UIImage(systemName: "magnifyingglass"),
                                    tag: 0)
        
        bookmarksSplitVC.tabBarItem = .init(title: Localizable.BOOKMARKS.string,
                                       image: UIImage(systemName: "bookmark"),
                                       tag: 1)
        bookmarksSplitVC.tabBarItem.selectedImage = UIImage(systemName: "bookmark.fill")
        
        settingsNVC.tabBarItem = .init(title: Localizable.SETTINGS.string,
                                       image: UIImage(systemName: "gearshape"),
                                       tag: 2)
        settingsNVC.tabBarItem.selectedImage = UIImage(systemName: "gearshape.fill")
        
        setViewControllers([searchSplitVC, bookmarksSplitVC, settingsNVC], animated: false)
    }
}
