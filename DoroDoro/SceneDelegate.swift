//
//  SceneDelegate.swift
//  DoroDoro
//
//  Created by Jinwoo Kim on 2/25/21.
//

import UIKit

internal final class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    internal var window: UIWindow?
    internal weak var mainTabBarController: MainTabBarController? = nil
    
    internal func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene: UIWindowScene = (scene as? UIWindowScene) else {
            fatalError("Failed to get UIWindowScene")
        }
        
        window = .init(windowScene: windowScene)
        
        let mainTabBarController: MainTabBarController = .init()
        self.mainTabBarController = mainTabBarController
        mainTabBarController.loadViewIfNeeded()
        window?.rootViewController = mainTabBarController
        window?.makeKeyAndVisible()
        
        if let shortcutItem = connectionOptions.shortcutItem {
            ShortcutService.shared.handle(for: shortcutItem)
        }
    }
    
    internal func sceneWillEnterForeground(_ scene: UIScene) {
        CloudService.shared.synchronize()
    }
    
    internal func sceneWillResignActive(_ scene: UIScene) {
        UIApplication.shared.shortcutItems = ShortcutService.getShortcutItems()
    }
    
    internal func windowScene(_ windowScene: UIWindowScene, performActionFor shortcutItem: UIApplicationShortcutItem, completionHandler: @escaping (Bool) -> Void) {
        ShortcutService.shared.handle(for: shortcutItem)
    }
}

