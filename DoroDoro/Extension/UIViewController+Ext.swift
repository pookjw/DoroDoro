//
//  UIViewController+Ext.swift
//  DoroDoro
//
//  Created by Jinwoo Kim on 3/1/21.
//

import UIKit

extension UIViewController {
    internal func showErrorAlert(for error: LocalizedError) {
        let alert: UIAlertController = .init(title: nil, message: error.errorDescription, preferredStyle: .alert)
        let doneAction: UIAlertAction = .init(title: Localizable.DONE.string, style: .default)
        alert.addAction(doneAction)
        present(alert, animated: true)
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
}
