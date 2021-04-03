//
//  SearchWindow.swift
//  DoroDoroMac
//
//  Created by Jinwoo Kim on 3/14/21.
//

import Cocoa
import Combine
import SnapKit

internal final class SearchWindow: NSWindow {
    internal let resizeEvent: PassthroughSubject<NSRect, Never> = .init()
    internal weak var searchVC: SearchViewController? = nil
    private var customUndoManager: UndoManager = .init()
    internal weak var locationToolbarItem: NSToolbarItem? = nil
    
    internal convenience init() {
        self.init(contentRect: .zero,
                  styleMask:  [.miniaturizable, .closable, .resizable, .titled, .fullSizeContentView],
                  backing: .buffered,
                  defer: false)
        let size: NSSize = .init(width: 400, height: 600)
        let searchVC: SearchViewController = .init()
        self.searchVC = searchVC
        searchVC.searchWindow = self
        searchVC.loadViewIfNeeded()
        
        contentMinSize = size
        contentViewController = searchVC
        title = Localizable.SEARCH.string
        subtitle = Localizable.DORODORO.string
        titlebarAppearsTransparent = true
        titleVisibility = .visible
        isMovableByWindowBackground = true
        delegate = self
        // https://stackoverflow.com/q/12216637
        isReleasedWhenClosed = false
        
        setCenter(offset: size)
        configureToolbar()
    }
    
    internal override func close() {
        super.close()
        NotificationCenter.default.removeObserver(self)
    }
    
    internal func toggleLocationToolbarItemStatus(isSearching: Bool) {
        let systemSymbolName: String = isSearching ? "location.fill" : "location"
        locationToolbarItem?.image = NSImage(systemSymbolName: systemSymbolName, accessibilityDescription: nil)
    }
    
    private func configureToolbar() {
        let toolbar: NSToolbar = .init()
        self.toolbar = toolbar
        toolbar.delegate = self
        toolbar.insertItem(withItemIdentifier: .locationIdentifier, at: 0)
        toolbar.validateVisibleItems()
    }
    
    private func getLocationToolbarItem() -> NSToolbarItem {
        let locationToolbarItem: NSToolbarItem = .init(itemIdentifier: .locationIdentifier)
        locationToolbarItem.action = #selector(clickedCurrentLocationToolbarItem(_:))
        locationToolbarItem.target = self
        locationToolbarItem.paletteLabel = "번역"
        locationToolbarItem.image = NSImage(systemSymbolName: "location", accessibilityDescription: nil)
        locationToolbarItem.isBordered = true
        
        return locationToolbarItem
    }
    
    @objc private func clickedCurrentLocationToolbarItem(_ sender: NSToolbarItem) {
        searchVC?.requestGeoEventIfAvailable()
    }
}

extension SearchWindow: NSWindowDelegate {
    internal func windowDidResize(_ notification: Notification) {
        resizeEvent.send(frame)
    }
    
    internal func windowWillReturnUndoManager(_ window: NSWindow) -> UndoManager? {
        return customUndoManager
    }
}

extension SearchWindow: NSToolbarDelegate {
    internal func toolbar(_ toolbar: NSToolbar, itemForItemIdentifier itemIdentifier: NSToolbarItem.Identifier, willBeInsertedIntoToolbar flag: Bool) -> NSToolbarItem? {
        
        if itemIdentifier == .locationIdentifier {
            let locationToolbarItem: NSToolbarItem = getLocationToolbarItem()
            self.locationToolbarItem = locationToolbarItem
            return locationToolbarItem
        } else {
            return nil
        }
    }
    
    internal func toolbarDefaultItemIdentifiers(_ toolbar: NSToolbar) -> [NSToolbarItem.Identifier] {
        return [.locationIdentifier]
    }
    
    internal func toolbarAllowedItemIdentifiers(_ toolbar: NSToolbar) -> [NSToolbarItem.Identifier] {
        return [.locationIdentifier]
    }
}
