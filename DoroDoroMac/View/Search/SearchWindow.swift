//
//  SearchWindow.swift
//  DoroDoroMac
//
//  Created by Jinwoo Kim on 3/14/21.
//

import Cocoa
import Combine

internal final class SearchWindow: NSWindow {
    internal let resizeEvent: PassthroughSubject<NSRect, Never> = .init()
    
    internal convenience init() {
        self.init(contentRect: .zero,
                  styleMask:  [.miniaturizable, .closable, .resizable, .titled, .fullSizeContentView],
                  backing: .buffered,
                  defer: false)
        let size: NSSize = .init(width: 400, height: 600)
        let searchVC: SearchViewController = .init()
        searchVC.searchWindow = self
        searchVC.preferredContentSize = size
        
        contentMinSize = size
        contentViewController = searchVC
        title = Localizable.DORODORO.string
        titlebarAppearsTransparent = true
        titleVisibility = .visible
        isMovableByWindowBackground = true
        delegate = self
        // https://stackoverflow.com/q/12216637
        isReleasedWhenClosed = false
        
        setCenter(offset: size)
    }
    
    private func configureMenu() {
        NSApp.mainMenu = SearchMenu(title: "")
    }
}

extension SearchWindow: NSWindowDelegate {
    internal func windowDidResize(_ notification: Notification) {
        resizeEvent.send(frame)
    }
    
    internal func windowDidBecomeMain(_ notification: Notification) {
        configureMenu()
    }
}
