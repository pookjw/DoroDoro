//
//  AppDelegate.swift
//  DoroDoroMac
//
//  Created by Jinwoo Kim on 3/14/21.
//

import Cocoa
import Combine

internal final class AppDelegate: NSObject, NSApplicationDelegate {
    private lazy var statusItem: NSStatusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
    private weak var popover: NSPopover? = nil
    private var cancellableBag: Set<AnyCancellable> = .init()
    
    internal func applicationDidFinishLaunching(_ aNotification: Notification) {
        configureMenu()
        configureBookmarksStatusBarItem()
        showSearchWindow()
        bind()
    }

    internal func applicationWillBecomeActive(_ notification: Notification) {
        CloudService.shared.synchronize()
    }
    
    /// Dock 아이콘 눌렀을 때
    internal func applicationShouldHandleReopen(_ sender: NSApplication, hasVisibleWindows flag: Bool) -> Bool {
        if sender.windows.filter({ $0 is SearchWindow }).isEmpty {
            showSearchWindow()
        }
        return true
    }
    
    internal func application(_ application: NSApplication, open urls: [URL]) {
        if let url: URL = urls.first {
            ShortcutService.shared.handle(for: url)
            print(url)
        }
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
        guard NSApp.windows.filter({ $0 is AboutWindow }).isEmpty else {
            return nil
        }
        
        let aboutWindow: AboutWindow = .init()
        aboutWindow.makeKeyAndOrderFront(nil)
        return aboutWindow
    }
    
    private func configureMenu() {
        NSApp.mainMenu = CustomMenu(title: Localizable.DORODORO.string)
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
        vc.popover = popover
        vc.preferredContentSize = .init(width: 400, height: 600)
        popover.contentViewController = vc
        popover.behavior = .semitransient
        popover.show(relativeTo: sender.bounds, of: sender, preferredEdge: .maxY)
    }
    
    private func bind() {
        ShortcutService.shared.typeEvent
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] type in
                self?.handleShortcutType(type)
            })
            .store(in: &cancellableBag)
    }
    
    private func handleShortcutType(_ type: ShortcutService.ShortcutType) {
        switch type {
        case .search(let text):
            if let searchWindow: SearchWindow = NSApp.windows.compactMap({ $0 as? SearchWindow }).last {
                searchWindow.orderFront(nil)
                searchWindow.searchVC?.search(for: text)
            } else {
                let searchWindow: SearchWindow = showSearchWindow()
                searchWindow.searchVC?.search(for: text)
            }
        case .searchCurrentLocation:
            if let searchWindow: SearchWindow = NSApp.windows.compactMap({ $0 as? SearchWindow }).last {
                searchWindow.orderFront(nil)
                searchWindow.searchVC?.requestGeoEventIfAvailable()
            } else {
                let searchWindow: SearchWindow = showSearchWindow()
                searchWindow.searchVC?.requestGeoEventIfAvailable()
            }
        case .bookmarks:
            if let button: NSStatusBarButton = statusItem.button,
               popover == nil {
                showBookmarksPopover(button)
            }
        }
    }
}
