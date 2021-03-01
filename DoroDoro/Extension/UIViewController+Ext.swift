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
}
