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
        self.init(contentRect: NSRect(x: 0, y: 0, width: 400, height: 400),
                  styleMask:  [.miniaturizable, .closable, .resizable, .titled],
                  backing: .buffered,
                  defer: false)
        let searchVC: SearchViewController = .init()
        searchVC.searchWindow = self
        
        contentMinSize = CGSize(width: 400, height: 400)
        contentViewController = searchVC
        title = Localizable.DORODORO.string
        titlebarAppearsTransparent = true
        titleVisibility = .visible
        isMovableByWindowBackground = true
        styleMask = [styleMask, .fullSizeContentView]
        delegate = self
    }
}

extension SearchWindow: NSWindowDelegate {
    internal func windowDidResize(_ notification: Notification) {
        resizeEvent.send(frame)
    }
}
