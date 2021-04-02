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
    internal func showErrorAlert(for error: Error,
                                 onTap: (() -> Void)? = nil,
                                 onSwipeUp: (() -> Void)? = nil)
    {
        let message: String?
        if let error: LocalizedError = error as? LocalizedError {
            message = error.errorDescription
        } else {
            message = error.localizedDescription
        }
        
        let imageView: UIImageView = .init(image: UIImage(systemName: "xmark.octagon"))
        imageView.tintColor = .white
        
        let banner: FloatingNotificationBanner = .init(title: Localizable.ERROR.string,
                                               subtitle: message,
                                               leftView: imageView,
                                               style: .danger)
        banner.onTap = onTap
        banner.onSwipeUp = onSwipeUp
        banner.show()
    }
    
    internal func showErrorAlert(message: String?,
                                 onTap: (() -> Void)? = nil,
                                 onSwipeUp: (() -> Void)? = nil)
    {
        let imageView: UIImageView = .init(image: UIImage(systemName: "xmark.octagon"))
        imageView.tintColor = .white
        
        let banner: FloatingNotificationBanner = .init(title: Localizable.ERROR.string,
                                               subtitle: message,
                                               leftView: imageView,
                                               style: .danger)
        banner.onTap = onTap
        banner.onSwipeUp = onSwipeUp
        banner.show()
    }
    
    internal func showSuccessAlert(message: String?,
                                   onTap: (() -> Void)? = nil,
                                   onSwipeUp: (() -> Void)? = nil)
    {
        let imageView: UIImageView = .init(image: UIImage(systemName: "checkmark.circle"))
        imageView.tintColor = .white
        
        let banner: FloatingNotificationBanner = .init(title: Localizable.SUCCESS.string,
                                               subtitle: message,
                                               leftView: imageView,
                                               style: .success)
        banner.onTap = onTap
        banner.onSwipeUp = onSwipeUp
        banner.show()
    }
    
    internal func showWarningAlert(for error: Error,
                                 onTap: (() -> Void)? = nil,
                                 onSwipeUp: (() -> Void)? = nil)
    {
        let message: String?
        if let error: LocalizedError = error as? LocalizedError {
            message = error.errorDescription
        } else {
            message = error.localizedDescription
        }
        
        let imageView: UIImageView = .init(image: UIImage(systemName: "exclamationmark.triangle"))
        imageView.tintColor = .white
        
        let banner: FloatingNotificationBanner = .init(title: Localizable.WARNING.string,
                                               subtitle: message,
                                               leftView: imageView,
                                               style: .warning)
        banner.onTap = onTap
        banner.onSwipeUp = onSwipeUp
        banner.show()
    }
    
    internal func showWarningAlert(message: String?,
                                 onTap: (() -> Void)? = nil,
                                 onSwipeUp: (() -> Void)? = nil)
    {
        let imageView: UIImageView = .init(image: UIImage(systemName: "exclamationmark.triangle"))
        imageView.tintColor = .white
        
        let banner: FloatingNotificationBanner = .init(title: Localizable.WARNING.string,
                                               subtitle: message,
                                               leftView: imageView,
                                               style: .warning)
        banner.onTap = onTap
        banner.onSwipeUp = onSwipeUp
        banner.show()
    }
    
    @discardableResult
    internal func share(_ items: [Any],
                        sourceView: UIView? = nil,
                        showCompletionAlert: Bool,
                        completion: (UIActivityViewController.CompletionWithItemsHandler)? = nil)
    -> UIActivityViewController {
        let ac: UIActivityViewController = .init(activityItems: items, applicationActivities: nil)
        
        if let controller: UIPopoverPresentationController = ac.popoverPresentationController {
            if let sourceView: UIView = sourceView {
                controller.sourceView = sourceView
            } else {
                controller.sourceView = view
                controller.sourceRect = CGRect(origin: view.center, size: .zero)
            }
        }
        
        if showCompletionAlert {
            ac.completionWithItemsHandler = { [weak self] (type, success, items, error) in
                if success {
                    self?.showSuccessAlert(message: nil)
                } else if let error: Error = error {
                    self?.showErrorAlert(for: error)
                }
                completion?(type, success, items, error)
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
                // collapsed 상태가 아닐 경우 deselect 안 되는 문제가 있기 때문
                collectionView?.deselectItem(at: indexPath, animated: animated)
            }
        }
    }
    
    internal func presentSFSafariViewController(_ url: URL) {
        let vc: SFSafariViewController = .init(url: url)
        present(vc, animated: true)
    }
}
