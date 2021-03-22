//
//  CustomMenu.swift
//  DoroDoroMac
//
//  Created by Jinwoo Kim on 3/21/21.
//

import Cocoa

internal final class CustomMenu: NSMenu {
    private weak var bookmarkMenuItem: NSMenuItem? = nil
    
    internal override init(title: String) {
        super.init(title: title)
        configureAppMenuItem()
        configureFileMenuItem()
        configureEditMenuItem()
        configureHelpMenuItem()
    }
    
    internal required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    internal func updateBookmarkMenuItem(target: AnyObject?, action: Selector?, bookmarked: Bool) {
        bookmarkMenuItem?.target = target
        bookmarkMenuItem?.action = action
        
        bookmarkMenuItem?.title = bookmarked ? Localizable.REMOVE_FROM_BOOKMARKS.string : Localizable.ADD_TO_BOOKMARKS.string
    }
    
    private func configureAppMenuItem() {
        let appName: String = NSApp.applicationName
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
        let closeWindowItem: NSMenuItem = .init(title: "창 닫기 (번역)",
                                                action: #selector(closeWindow(_:)),
                                                keyEquivalent: "w")
        
        fileMenuItem.submenu = fileSubMenu
        fileSubMenu.items = [
            newItem,
            closeWindowItem
        ]
        
        newItem.title = "New... (번역)"
        newItem.submenu = newSubMenu
        newSubMenu.items = [
            newWindowItem,
        ]
        
        newWindowItem.target = self
        closeWindowItem.target = self
        
        items.append(fileMenuItem)
    }
    
    private func configureEditMenuItem() {
        let editMenuItem: NSMenuItem = .init()
        let editSubMenu: NSMenu = .init(title: "편집 (번역)")
        
        let cutMenuItem: NSMenuItem = .init(title: "잘라내기 (번역)",
                                            action: #selector(NSText.cut(_:)),
                                            keyEquivalent: "x")
        let copyMenuItem: NSMenuItem = .init(title: "복사 (번역)",
                                             action: #selector(NSText.copy(_:)),
                                             keyEquivalent: "c")
        let deleteMenuItem: NSMenuItem = .init(title: "삭제 (번역)",
                                               action: #selector(NSText.delete(_:)),
                                               keyEquivalent: String(describing: Character(UnicodeScalar(0x0008))))
        let selectAllMenuItem: NSMenuItem = .init(title: "모두 선택 (번역)",
                                                  action: #selector(NSText.selectAll(_:)),
                                                  keyEquivalent: "a")
        let bookmarkMenuItem: NSMenuItem = .init(title: "책갈피 추가/삭제 (번역)",
                                                 action: nil,
                                                 keyEquivalent: "b")
        self.bookmarkMenuItem = bookmarkMenuItem
        
        editMenuItem.submenu = editSubMenu
        editSubMenu.items = [
            cutMenuItem,
            copyMenuItem,
            deleteMenuItem,
            .separator(),
            selectAllMenuItem,
            .separator(),
            bookmarkMenuItem
        ]
        
        items.append(editMenuItem)
    }
    
    private func configureHelpMenuItem() {
        let helpMenuItem: NSMenuItem = .init()
        let helpSubMenu: NSMenu = .init(title: "도움말 (번역)")
        
        let showHelpMenuItem: NSMenuItem = .init(title: "도움말 (번역)",
                                             action: #selector(NSApp.showHelp(_:)),
                                             keyEquivalent: "")
        
        helpMenuItem.submenu = helpSubMenu
        helpSubMenu.items = [
            showHelpMenuItem
        ]
        
        items.append(helpMenuItem)
    }
    
    @objc private func showAboutWindow(_ sender: NSMenuItem) {
        guard let appDelegate: AppDelegate = NSApp.delegate as? AppDelegate else {
            return
        }
        appDelegate.showAboutWindow()
    }
    
    @objc private func showSearchWindow(_ sender: NSMenuItem) {
        guard let appDelegate: AppDelegate = NSApp.delegate as? AppDelegate else {
            return
        }
        appDelegate.showSearchWindow()
    }
    
    @objc private func closeWindow(_ sender: NSMenuItem) {
        NSApp.mainWindow?.close()
    }
}
