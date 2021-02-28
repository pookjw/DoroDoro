//
//  SceneDelegate.swift
//  DoroDoro
//
//  Created by Jinwoo Kim on 2/25/21.
//

import UIKit

final internal class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    internal var window: UIWindow?
    internal weak var mainTabBarController: MainTabBarController? = nil
    
    internal func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene: UIWindowScene = (scene as? UIWindowScene) else {
            fatalError("Failed to get UIWindowScene")
        }
        
        window = .init(windowScene: windowScene)
        
        let mainTabBarController: MainTabBarController = .init()
        self.mainTabBarController = mainTabBarController
        window?.rootViewController = mainTabBarController
        window?.makeKeyAndVisible()
    }
}

