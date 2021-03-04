//
//  DetailedNVCSplitViewControllerDelegate.swift
//  DoroDoro
//
//  Created by Jinwoo Kim on 3/5/21.
//

import UIKit

final internal class DetailedNVCSplitViewControllerDelegate: UISplitViewControllerDelegate {
    func splitViewController(_ splitViewController: UISplitViewController, showDetail vc: UIViewController, sender: Any?) -> Bool {
        guard !splitViewController.isCollapsed else {
            return false
        }
        
        let secondaryNavigationController: UINavigationController = .init(rootViewController: vc)
        if splitViewController.viewControllers.count < 2 {
            splitViewController.viewControllers.append(secondaryNavigationController)
        } else {
            splitViewController.viewControllers[1] = secondaryNavigationController
        }
        
        return true
    }

    func splitViewController(_ splitViewController: UISplitViewController, collapseSecondary secondaryViewController: UIViewController, onto primaryViewController: UIViewController) -> Bool {
        guard let secondaryNavigationController: UINavigationController = secondaryViewController as? UINavigationController,
            let primaryNavigationController: UINavigationController = primaryViewController as? UINavigationController else {
            return false
        }
        
        primaryNavigationController.viewControllers.append(contentsOf: secondaryNavigationController.viewControllers)
        return true
    }


    func splitViewController(_ splitViewController: UISplitViewController, separateSecondaryFrom primaryViewController: UIViewController) -> UIViewController? {
        guard let primaryNavigationController: UINavigationController = primaryViewController as? UINavigationController else {
            return nil
        }
        
        guard primaryNavigationController.viewControllers.count > 1 else {
            return nil
        }
        
        guard let secondaryViewController: UIViewController = primaryNavigationController.viewControllers.popLast() else {
            return nil
        }
        
        if secondaryViewController is UINavigationController {
            return secondaryViewController
        }
        
        let secondaryNavigationController: UINavigationController = .init(rootViewController: secondaryViewController)
        return secondaryNavigationController
    }
}
