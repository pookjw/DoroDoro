//
//  WKInterfaceController+Ext.swift
//  DoroDoroWatch Extension
//
//  Created by Jinwoo Kim on 3/6/21.
//

import WatchKit

extension WKInterfaceController {
    internal func showErrorAlert(for error: LocalizedError) {
        let doneAction: WKAlertAction = .init(title: Localizable.DONE.string,
                                              style: .default) {}
        presentAlert(withTitle: "ERROR!(번역필요)",
                           message: error.errorDescription,
                           preferredStyle: .alert,
                           actions: [doneAction])
    }
}
