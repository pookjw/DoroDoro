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
        
        guard let secondaryNavigationController: UINavigationController = splitViewController.viewControllers[1] as? UINavigationController else {
            return false
        }
        
        secondaryNavigationController.viewControllers = [vc]
        
        return true
    }

    func splitViewController(_ splitViewController: UISplitViewController, collapseSecondary secondaryViewController: UIViewController, onto primaryViewController: UIViewController) -> Bool {
        guard let primaryNavigationController: UINavigationController = primaryViewController as? UINavigationController else {
            return false
        }
        
        guard let secondaryNavigationController: UINavigationController = secondaryViewController as? UINavigationController else {
            return false
        }
        
        primaryNavigationController.viewControllers.append(contentsOf: secondaryNavigationController.viewControllers)
        secondaryNavigationController.viewControllers = []
        
        return true
    }


    func splitViewController(_ splitViewController: UISplitViewController, separateSecondaryFrom primaryViewController: UIViewController) -> UIViewController? {
        guard let primaryNavigationController: UINavigationController = primaryViewController as? UINavigationController else {
            return nil
        }
        
        let primaryNavigationControllersCount: Int = primaryNavigationController.viewControllers.count
        
        guard primaryNavigationControllersCount > 1 else {
            return UINavigationController()
        }
        
        let secondaryViewControllers: [UIViewController] = Array(primaryNavigationController.viewControllers[1..<primaryNavigationControllersCount])
        primaryNavigationController.viewControllers = [primaryNavigationController.viewControllers[0]]
        
        let secondaryNavigationController: UINavigationController = .init()
        secondaryNavigationController.viewControllers = secondaryViewControllers
        return secondaryNavigationController
    }
    
    func splitViewController(_ svc: UISplitViewController, topColumnForCollapsingToProposedTopColumn proposedTopColumn: UISplitViewController.Column) -> UISplitViewController.Column {
        return .primary
    }
}
