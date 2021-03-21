//
//  AppDelegate.swift
//  DoroDoroMac
//
//  Created by Jinwoo Kim on 3/14/21.
//

import Cocoa

internal final class AppDelegate: NSObject, NSApplicationDelegate {
    private lazy var statusItem: NSStatusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
    
    internal func applicationDidFinishLaunching(_ aNotification: Notification) {
        configureMenu()
        configureBookmarksStatusBarItem()
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
    
    private func configureBookmarksStatusBarItem() {
        statusItem.button?.image = NSImage(systemSymbolName: "signpost.right.fill", accessibilityDescription: nil)
        statusItem.button?.action = #selector(showBookmarksPopover(_:))
        statusItem.button?.target = self
    }
    
    @objc private func showBookmarksPopover(_ sender: NSStatusBarButton) {
        let vc: BookmarksViewController = .init()
        let popover: NSPopover = .init()
        vc.preferredContentSize = .init(width: 400, height: 600)
        popover.contentViewController = vc
        popover.behavior = .transient
        popover.show(relativeTo: sender.bounds, of: sender, preferredEdge: .maxY)
    }
}
