//
//  AppDelegate.swift
//  DoroDoroMac
//
//  Created by Jinwoo Kim on 3/14/21.
//

import Cocoa

internal final class AppDelegate: NSObject, NSApplicationDelegate {
    
    internal func applicationDidFinishLaunching(_ aNotification: Notification) {
        configureMenu()
        showSearchWindow()
    }

    internal func applicationWillBecomeActive(_ notification: Notification) {
        CloudService.shared.synchronize()
    }

    @discardableResult
    internal func showSearchWindow() -> SearchWindow {
        let searchWindow: SearchWindow = .init()
        searchWindow.makeKeyAndOrderFront(nil)
        return searchWindow
    }
    
    @discardableResult
    internal func showAboutWindow() -> AboutWindow? {
        guard NSApplication.shared.windows.filter({ $0 is AboutWindow }).isEmpty else {
            return nil
        }
        
        let aboutWindow: AboutWindow = .init()
        aboutWindow.makeKeyAndOrderFront(nil)
        return aboutWindow
    }
    
    private func configureMenu() {
        NSApp.mainMenu = CustomMenu(title: "")
    }
}
