//
//  CustomMenu.swift
//  DoroDoroMac
//
//  Created by Jinwoo Kim on 3/21/21.
//

import Cocoa

internal final class CustomMenu: NSMenu {
    internal override init(title: String) {
        super.init(title: title)
        configureAppMenuItem()
        configureFileMenuItem()
    }
    
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configureAppMenuItem() {
        let appName: String = NSApplication.shared.applicationName
        let appMenuItem: NSMenuItem = .init()
        let appSubMenu: NSMenu = .init(title: appName)
        
        let aboutAppItem: NSMenuItem = .init(title: "About \(appName) (번역)",
                                             action: #selector(showAboutWindow(_:)),
                                             keyEquivalent: "")
        let hideAppItem: NSMenuItem = .init(title: "Hide \(appName) (번역)",
                                            action: #selector(NSApp.hide(_:)),
                                            keyEquivalent: "h")
        let hideOhtersItem: NSMenuItem = .init(title: "Hide Others (번역)",
                                               action: #selector(NSApp.hideOtherApplications(_:)),
                                               keyEquivalent: "h")
        let quitAppItem: NSMenuItem = .init(title: "Quit \(appName) (번역)",
                                            action: #selector(NSApp.terminate(_:)),
                                            keyEquivalent: "q")
        
        aboutAppItem.target = self
        hideOhtersItem.keyEquivalentModifierMask = [.shift, .command]
        
        appMenuItem.submenu = appSubMenu
        appSubMenu.items = [
            aboutAppItem,
            .separator(),
            hideAppItem,
            hideOhtersItem,
            .separator(),
            quitAppItem
        ]
        
        items.append(appMenuItem)
    }
    
    private func configureFileMenuItem() {
        let fileMenuItem: NSMenuItem = .init()
        let fileSubMenu: NSMenu = .init(title: "파일 (번역)")
        
        let newItem: NSMenuItem = .init()
        let newSubMenu: NSMenu = .init()
        
        let newWindowItem: NSMenuItem = .init(title: "새 창 (번역)",
                                              action: #selector(showSearchWindow(_:)),
                                              keyEquivalent: "n")
        
        fileMenuItem.submenu = fileSubMenu
        fileSubMenu.items = [
            newItem
        ]
        
        newItem.title = "New... (번역)"
        newItem.submenu = newSubMenu
        newSubMenu.items = [
            newWindowItem
        ]
        
        newWindowItem.target = self
        
        items.append(fileMenuItem)
    }
    
    @objc private func showAboutWindow(_ sender: NSMenuItem) {
        guard let appDelegate: AppDelegate = NSApplication.shared.delegate as? AppDelegate else {
            return
        }
        appDelegate.showAboutWindow()
    }
    
    @objc private func showSearchWindow(_ sender: NSMenuItem) {
        guard let appDelegate: AppDelegate = NSApplication.shared.delegate as? AppDelegate else {
            return
        }
        appDelegate.showSearchWindow()
    }
}
