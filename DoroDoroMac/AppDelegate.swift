//
//  AppDelegate.swift
//  DoroDoroMac
//
//  Created by Jinwoo Kim on 3/14/21.
//

import Cocoa

internal final class AppDelegate: NSObject, NSApplicationDelegate {
    
    internal func applicationDidFinishLaunching(_ aNotification: Notification) {
        configureSearchWindow()
    }

    internal func applicationWillBecomeActive(_ notification: Notification) {
        CloudService.shared.synchronize()
    }

    @discardableResult
    private func configureSearchWindow() -> SearchWindow {
        let searchWindow: SearchWindow = .init()
        searchWindow.makeKeyAndOrderFront(nil)
        return searchWindow
    }
}

