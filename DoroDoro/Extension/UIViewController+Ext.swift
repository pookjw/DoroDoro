//
//  UIViewController+Ext.swift
//  DoroDoro
//
//  Created by Jinwoo Kim on 3/1/21.
//

import UIKit
import SafariServices
import NotificationBannerSwift

extension UIViewController {
    internal func showErrorAlert(for error: Error) {
        let message: String?
        if let error: LocalizedError = error as? LocalizedError {
            message = error.errorDescription
        } else {
            message = error.localizedDescription
        }
        
        let imageView: UIImageView = .init(image: UIImage(systemName: "xmark.octagon"))
        imageView.tintColor = .white
        
        let banner: FloatingNotificationBanner = .init(title: "에러!!!(번역필요)",
                                               subtitle: message,
                                               leftView: imageView,
                                               style: .danger)
        banner.show()
    }
    
    @discardableResult
    internal func share(_ items: [Any], sourceView: UIView? = nil) -> UIActivityViewController {
        let ac: UIActivityViewController = .init(activityItems: items, applicationActivities: nil)
        
        if let controller: UIPopoverPresentationController = ac.popoverPresentationController {
            if let sourceView: UIView = sourceView {
                controller.sourceView = sourceView
            } else {
                controller.sourceView = view
                controller.sourceRect = CGRect(origin: view.center, size: .zero)
            }
        }
        
        present(ac, animated: true)
        return ac
    }
    
    internal func animateForSelectedIndexPath(_ collectionView: UICollectionView, animated: Bool) {
        collectionView.indexPathsForSelectedItems?.forEach { [weak self, weak collectionView] indexPath in
            if let coordinator: UIViewControllerTransitionCoordinator = self?.transitionCoordinator {
                coordinator.animate(alongsideTransition: { context in
                    collectionView?.deselectItem(at: indexPath, animated: true)
                }, completion: { context in
                    if context.isCancelled {
                        collectionView?.selectItem(at: indexPath, animated: false, scrollPosition: .left)
                    }
                })
            } else if let isCollapsed: Bool = splitViewController?.isCollapsed, isCollapsed {
                collectionView?.deselectItem(at: indexPath, animated: animated)
            }
        }
    }
    
    internal func presentSFSafariViewController(_ url: URL) {
        let vc: SFSafariViewController = .init(url: url)
        present(vc, animated: true)
    }
}
