//
//  SceneDelegate.swift
//  DoroDoro
//
//  Created by Jinwoo Kim on 2/25/21.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    var window: UIWindow?
    
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene: UIWindowScene = (scene as? UIWindowScene) else {
            fatalError("Failed to get UIWindowScene")
        }
        
        window = .init(windowScene: windowScene)
        
        let vc: ViewController = .init()
        window?.rootViewController = vc
        window?.makeKeyAndVisible()
    }
}

