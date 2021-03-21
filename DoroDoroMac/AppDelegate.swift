//
//  AppDelegate.swift
//  DoroDoroMac
//
//  Created by Jinwoo Kim on 3/14/21.
//

import Cocoa

internal final class AppDelegate: NSObject, NSApplicationDelegate {
    private lazy var statusItem: NSStatusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
    private weak var popover: NSPopover? = nil
    
    internal func applicationDidFinishLaunching(_ aNotification: Notification) {
        configureMenu()
        configureBookmarksStatusBarItem()
        showSearchWindow()
    }

    internal func applicationWillBecomeActive(_ notification: Notification) {
        CloudService.shared.synchronize()
    }
    
    /// Dock 아이콘 눌렀을 때
    internal func applicationShouldHandleReopen(_ sender: NSApplication, hasVisibleWindows flag: Bool) -> Bool {
        guard sender.windows.filter({ $0 is SearchWindow }).isEmpty else {
            return true
        }
        showSearchWindow()
        return true
    }
    
    //

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
        // 이미 열려 있으면 닫는다
        guard popover == nil else {
            popover?.close()
            return
        }
        
        let vc: BookmarksViewController = .init()
        let popover: NSPopover = .init()
        self.popover = popover
        vc.preferredContentSize = .init(width: 400, height: 600)
        popover.contentViewController = vc
        popover.behavior = .semitransient
        popover.show(relativeTo: sender.bounds, of: sender, preferredEdge: .maxY)
    }
}
