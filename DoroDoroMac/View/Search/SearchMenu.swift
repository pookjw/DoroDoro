//
//  SearchMenu.swift
//  DoroDoroMac
//
//  Created by Jinwoo Kim on 3/21/21.
//

import Cocoa

internal final class SearchMenu: NSMenu {
    internal override init(title: String) {
        super.init(title: title)
        configureAppMenuItem()
    }
    
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configureAppMenuItem() {
        let appName: String = NSApplication.shared.applicationName
        let appMenuItem: NSMenuItem = .init()
        let appSubMenu: NSMenu = .init(title: appName)
        
        let aboutApp: NSMenuItem = .init(title: "About \(appName) (번역)", action: #selector(showAboutWindow(_:)), keyEquivalent: "")
        let hideApp: NSMenuItem = .init(title: "Hide \(appName) (번역)", action: #selector(NSApp.hide(_:)), keyEquivalent: "h")
        let hideOhters: NSMenuItem = .init(title: "Hide Others (번역)", action: #selector(NSApp.hideOtherApplications(_:)), keyEquivalent: "h")
        let quitApp: NSMenuItem = .init(title: "Quit \(appName) (번역)", action: #selector(NSApp.terminate(_:)), keyEquivalent: "q")
        
        aboutApp.target = self
        hideOhters.keyEquivalentModifierMask = [.shift, .command]
        
        appMenuItem.submenu = appSubMenu
        appSubMenu.items = [
            aboutApp,
            .separator(),
            hideApp,
            hideOhters,
            .separator(),
            quitApp
        ]
        
        items.append(appMenuItem)
    }
    
    @objc private func showAboutWindow(_ sender: Any) {
        guard NSApplication.shared.windows.filter({ $0 is AboutWindow }).isEmpty else {
            return
        }
        
        let aboutWindow: AboutWindow = .init()
        aboutWindow.makeKeyAndOrderFront(nil)
    }
}
