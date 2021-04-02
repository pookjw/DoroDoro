//
//  MainTabBarController.swift
//  DoroDoro
//
//  Created by Jinwoo Kim on 2/25/21.
//

import UIKit
import Combine

internal final class MainTabBarController: UITabBarController {
    internal weak var searchVC: SearchViewController? = nil
    internal weak var bookmarksVC: BookmarksViewController? = nil
    internal weak var settingsVC: SettingsViewController? = nil
    internal weak var searchSplitVC: UISplitViewController? = nil
    internal weak var bookmarksSplitVC: UISplitViewController? = nil
    
    internal var splitVCDelegate: DetailedNVCSplitViewControllerDelegate = .init()
    private var cancellableBag: Set<AnyCancellable> = .init()
    
    internal override func viewDidLoad() {
        super.viewDidLoad()
        setAttributes()
        configureViewControllers()
        bind()
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
        self.searchSplitVC = searchSplitVC
        self.bookmarksSplitVC = bookmarksSplitVC
        
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
    
    private func bind() {
        ShortcutService.shared.typeEvent
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] type in
                guard let self = self else { return }
                switch type {
                case .search(_), .searchCurrentLocation:
                    guard let searchSplitVC: UISplitViewController = self.searchSplitVC else { return }
                    self.makeFirstPage(for: searchSplitVC, select: true)
                case .bookmark(_):
                    guard let bookmarksSplitVC: UISplitViewController = self.bookmarksSplitVC else { return }
                    self.makeFirstPage(for: bookmarksSplitVC, select: true)
                }
            })
            .store(in: &cancellableBag)
    }
    
    private func makeFirstPage(for splitViewController: UIViewController, select: Bool) {
        guard let splitViewController: UISplitViewController = splitViewController as? UISplitViewController,
            let primaryNavigationController: UINavigationController = splitViewController.viewControllers.first as? UINavigationController,
              let firstViewController: UIViewController = primaryNavigationController.viewControllers.first else {
            return
        }
        
        primaryNavigationController.setViewControllers([firstViewController], animated: true)
        if select {
            selectedViewController = splitViewController
        }
    }
    
    private func scrollCollectionViewToTop(for splitViewController: UIViewController) {
        guard let splitViewController: UISplitViewController = splitViewController as? UISplitViewController,
            let primaryNavigationController: UINavigationController = splitViewController.viewControllers.first as? UINavigationController,
              let firstViewController: UIViewController = primaryNavigationController.viewControllers.first else {
            return
        }
        
        if let searchVC: SearchViewController = firstViewController as? SearchViewController {
            searchVC.scrollCollectionViewToTop()
        } else if let bookmarksVC: BookmarksViewController = firstViewController as? BookmarksViewController {
            bookmarksVC.scrollCollectionViewToTop()
        } else if let settingsVC: SettingsViewController = firstViewController as? SettingsViewController {
            settingsVC.scrollCollectionViewToTop()
        }
    }
}

extension MainTabBarController: UITabBarControllerDelegate {
    internal func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {
        // 이미 선택된 상태에서 한 번 더 눌렀을 때만
        guard tabBarController.selectedViewController == viewController else {
            return true
        }
        
        guard let splitViewController: UISplitViewController = viewController as? UISplitViewController,
              let primaryNavigationController: UINavigationController = splitViewController.viewControllers.first as? UINavigationController else {
            return true
        }
        
        // Navigation Controller의 View Controller의 개수가 1개인 경우
        if primaryNavigationController.viewControllers.count == 1 {
            scrollCollectionViewToTop(for: viewController)
        } else {
            makeFirstPage(for: viewController, select: false)
        }
        
        return true
    }
}
