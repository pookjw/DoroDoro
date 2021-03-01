//
//  IntroBulletinManager.swift
//  DoroDoro
//
//  Created by Jinwoo Kim on 3/2/21.
//

import UIKit
import BLTNBoard

final internal class IntroBulletinManager {
    internal private(set) var bulletinManager: BLTNItemManager? = nil
    
    internal init() {
        configureBulletinManager()
    }
    
    private func configureBulletinManager() {
        let bulletinManager: BLTNItemManager = .init(rootItem: getWelcomePageItem())
        bulletinManager.backgroundViewStyle = .blurredDark
        bulletinManager.statusBarAnimation = .fade
        bulletinManager.statusBarAppearance = .hidden
        self.bulletinManager = bulletinManager
    }
    
    private func getWelcomePageItem() -> WelcomeBLTNPageItem {
        let welcomePageItem: WelcomeBLTNPageItem = .init(title: "Welcone!")
        welcomePageItem.descriptionText = "Hello!"
        welcomePageItem.image = UIImage(named: "bigsmile")
        welcomePageItem.isDismissable = true
        welcomePageItem.actionButtonTitle = "Continue"
        welcomePageItem.alternativeButtonTitle = "Skip"
        bulletinManager?.allowsSwipeInteraction = true
        
        welcomePageItem.actionHandler = { item in
            item.manager?.displayNextItem()
        }
        
        welcomePageItem.alternativeHandler = { item in
            item.manager?.dismissBulletin(animated: true)
        }
        
        welcomePageItem.next = getSearchGuidePageItem()
        return welcomePageItem
    }
    
    private func getSearchGuidePageItem() -> SearchGuideBLTNPageItem {
        let searchGuidePageItem: SearchGuideBLTNPageItem = .init(title: "You can Search!")
        searchGuidePageItem.descriptionText = "Like this!"
        searchGuidePageItem.image = UIImage(named: "looking")
        searchGuidePageItem.isDismissable = false
        searchGuidePageItem.actionButtonTitle = "Continue"
        bulletinManager?.allowsSwipeInteraction = false
        return searchGuidePageItem
    }
}
