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
    private weak var searchViewController: SearchViewController? = nil
    
    internal convenience init() {
        self.init(contentRect: .zero,
                  styleMask:  [.miniaturizable, .closable, .resizable, .titled, .fullSizeContentView],
                  backing: .buffered,
                  defer: false)
        let size: NSSize = .init(width: 400, height: 600)
        let searchViewController: SearchViewController = .init()
        self.searchViewController = searchViewController
        searchViewController.searchWindow = self
        
        contentMinSize = size
        contentViewController = searchViewController
        title = Localizable.DORODORO.string
        titlebarAppearsTransparent = true
        titleVisibility = .visible
        isMovableByWindowBackground = true
        delegate = self
        // https://stackoverflow.com/q/12216637
        isReleasedWhenClosed = false
        
        setCenter(offset: size)
    }
    
    internal override func close() {
        super.close()
        NotificationCenter.default.removeObserver(self)
    }
}

extension SearchWindow: NSWindowDelegate {
    internal func windowDidResize(_ notification: Notification) {
        resizeEvent.send(frame)
    }
}
