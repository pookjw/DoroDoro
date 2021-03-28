//
//  CustomMenu.swift
//  DoroDoroMac
//
//  Created by Jinwoo Kim on 3/21/21.
//

import Cocoa

internal final class CustomMenu: NSMenu {
    private weak var undoMenuItem: NSMenuItem? = nil
    private weak var redoMenuItem: NSMenuItem? = nil
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
    
    internal func isUndoMenuItem(_ compareToItem: NSMenuItem) -> Bool {
        return undoMenuItem == compareToItem
    }
    
    internal func isRedoMenuItem(_ compareToItem: NSMenuItem) -> Bool {
        return redoMenuItem == compareToItem
    }
    
    private func configureAppMenuItem() {
        let appName: String = Localizable.DORODORO.string
        let appMenuItem: NSMenuItem = .init()
        let appSubMenu: NSMenu = .init(title: appName)
        
        let aboutAppItem: NSMenuItem = .init(title: String(format: Localizable.MAC_MENU_ABOUT_APP.string, appName),
                                             action: #selector(showAboutWindow(_:)),
                                             keyEquivalent: "")
        let hideAppItem: NSMenuItem = .init(title: String(format: Localizable.MAC_MENU_HIDE_APP.string, appName),
                                            action: #selector(NSApp.hide(_:)),
                                            keyEquivalent: "h")
        let hideOhtersItem: NSMenuItem = .init(title: Localizable.MAC_MENU_HIDE_OTHERS.string,
                                               action: #selector(NSApp.hideOtherApplications(_:)),
                                               keyEquivalent: "h")
        let quitAppItem: NSMenuItem = .init(title: String(format: Localizable.MAC_MENU_QUIT_APP.string, appName),
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
        let fileSubMenu: NSMenu = .init(title: Localizable.MAC_MENU_FILE.string)
        
        let newItem: NSMenuItem = .init()
        let newSubMenu: NSMenu = .init()
        
        let newWindowItem: NSMenuItem = .init(title: Localizable.MAC_MENU_NEW_WINDOW.string,
                                              action: #selector(showSearchWindow(_:)),
                                              keyEquivalent: "n")
        let closeWindowItem: NSMenuItem = .init(title: Localizable.MAC_MENU_CLOSE_WINDOW.string,
                                                action: #selector(closeWindow(_:)),
                                                keyEquivalent: "w")
        
        fileMenuItem.submenu = fileSubMenu
        fileSubMenu.items = [
            newItem,
            closeWindowItem
        ]
        
        newItem.title = Localizable.MAC_MENU_NEW.string
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
        let editSubMenu: NSMenu = .init(title: Localizable.MAC_MENU_EDIT.string)
        
        let undoMenuItem: NSMenuItem = .init(title: Localizable.MAC_MENU_UNDO.string,
                                             action: Selector(("undoFromMenu:")),
                                             keyEquivalent: "z")
        let redoMenuItem: NSMenuItem = .init(title: Localizable.MAC_MENU_REDO.string,
                                             action: Selector(("redoFromMenu:")),
                                             keyEquivalent: "z")
        let cutMenuItem: NSMenuItem = .init(title: Localizable.MAC_MENU_REDO.string,
                                            action: #selector(NSText.cut(_:)),
                                            keyEquivalent: "x")
        let copyMenuItem: NSMenuItem = .init(title: Localizable.MAC_MENU_COPY.string,
                                             action: #selector(NSText.copy(_:)),
                                             keyEquivalent: "c")
        let pasteMenuItem: NSMenuItem = .init(title: Localizable.MAC_MENU_PASTE.string,
                                              action: #selector(NSText.paste(_:)),
                                              keyEquivalent: "v")
//        let deleteMenuItem: NSMenuItem = .init(title: "삭제 (번역)",
//                                               action: #selector(NSText.delete(_:)),
//                                               keyEquivalent: String(describing: Character(UnicodeScalar(0x0008))))
        let selectAllMenuItem: NSMenuItem = .init(title: Localizable.MAC_MENU_SELECT_ALL.string,
                                                  action: #selector(NSText.selectAll(_:)),
                                                  keyEquivalent: "a")
        let bookmarkMenuItem: NSMenuItem = .init(title: Localizable.ADD_TO_BOOKMARKS.string,
                                                 action: nil,
                                                 keyEquivalent: "b")
        
        self.undoMenuItem = undoMenuItem
        self.redoMenuItem = redoMenuItem
        self.bookmarkMenuItem = bookmarkMenuItem
        
        editMenuItem.submenu = editSubMenu
        editSubMenu.items = [
            undoMenuItem,
            redoMenuItem,
            .separator(),
            cutMenuItem,
            copyMenuItem,
            pasteMenuItem,
//            deleteMenuItem,
            .separator(),
            selectAllMenuItem,
            .separator(),
            bookmarkMenuItem
        ]
        
        items.append(editMenuItem)
        
        redoMenuItem.keyEquivalentModifierMask = [.shift, .command]
    }
    
    private func configureHelpMenuItem() {
        let appName: String = Localizable.DORODORO.string
        let helpMenuItem: NSMenuItem = .init()
        let helpSubMenu: NSMenu = .init(title: Localizable.MAC_MENU_HELP.string)
        
        let showHelpMenuItem: NSMenuItem = .init(title: String(format: Localizable.MAC_MENU_APP_HELP.string, appName),
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
