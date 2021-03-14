//
//  NSViewController+Ext.swift
//  DoroDoroMac
//
//  Created by Jinwoo Kim on 3/14/21.
//

import Cocoa

extension NSViewController {
    internal var window: NSWindow? {
        view.window
    }
    
    internal func showErrorAlert(for error: Error,
                                 completion: ((NSApplication.ModalResponse) -> Void)? = nil) {
        let alert: NSAlert = .init()
        alert.alertStyle = .critical
        alert.messageText = Localizable.ERROR.string
        
        if let error: LocalizedError = error as? LocalizedError {
            alert.informativeText = error.errorDescription ?? ""
        } else {
            alert.informativeText = error.localizedDescription
        }
        
        if let window: NSWindow = window {
            alert.beginSheetModal(for: window, completionHandler: completion)
        } else {
            alert.runModal()
        }
    }
    
    internal func showErrorAlert(message: String,
                                 completion: ((NSApplication.ModalResponse) -> Void)? = nil) {
        let alert: NSAlert = .init()
        alert.alertStyle = .critical
        alert.messageText = Localizable.ERROR.string
        alert.informativeText = message
        
        if let window: NSWindow = window {
            alert.beginSheetModal(for: window, completionHandler: completion)
        } else {
            alert.runModal()
        }
    }
}
