//
//  MainTabBarController.swift
//  DoroDoro
//
//  Created by Jinwoo Kim on 2/25/21.
//

import UIKit

internal final class MainTabBarController: UITabBarController {
    internal weak var searchVC: SearchViewController? = nil
    internal weak var bookmarksVC: BookmarksViewController? = nil
    internal weak var settingsVC: SettingsViewController? = nil
    
    internal var splitVCDelegate: DetailedNVCSplitViewControllerDelegate = .init()
    
    internal override func viewDidLoad() {
        super.viewDidLoad()
        setAttributes()
        configureViewControllers()
    }
    
    internal override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    private func setAttributes() {
        delegate = self
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

extension MainTabBarController: UITabBarControllerDelegate {
    internal func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {
        // 이미 선택된 상태에서 한 번 더 눌렀을 때만
        guard tabBarController.selectedViewController == viewController else {
            return true
        }
        
        guard let splitViewController: UISplitViewController = viewController as? UISplitViewController,
            let primaryNavigationController: UINavigationController = splitViewController.viewControllers.first as? UINavigationController,
              let firstViewController: UIViewController = primaryNavigationController.viewControllers.first else {
            return true
        }
        
        // Navigation Controller의 View Controller의 개수가 1개인 경우
        if primaryNavigationController.viewControllers.count == 1 {
            if let searchVC: SearchViewController = firstViewController as? SearchViewController {
                searchVC.scrollCollectionViewToTop()
            } else if let bookmarksVC: BookmarksViewController = firstViewController as? BookmarksViewController {
                bookmarksVC.scrollCollectionViewToTop()
            } else if let settingsVC: SettingsViewController = firstViewController as? SettingsViewController {
                settingsVC.scrollCollectionViewToTop()
            }
        } else {
            primaryNavigationController.setViewControllers([firstViewController], animated: true)
        }
        
        return true
    }
}
