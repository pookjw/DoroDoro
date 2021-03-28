//
//  AboutWindow.swift
//  DoroDoroMac
//
//  Created by Jinwoo Kim on 3/22/21.
//

import Cocoa

internal final class AboutWindow: NSWindow {
    private weak var aboutVC: AboutViewController? = nil
    
    internal convenience init() {
        self.init(contentRect: .zero,
                  styleMask:  [.closable, .titled, .fullSizeContentView],
                  backing: .buffered,
                  defer: false)
        let size: NSSize = .init(width: 300, height: 300)
        let aboutVC: AboutViewController = .init()
        self.aboutVC = aboutVC
        aboutVC.abountWindow = self
        aboutVC.preferredContentSize = size
        
        contentViewController = aboutVC
        title = String(format: Localizable.MAC_ABOUT_TITLE.string, Localizable.DORODORO.string)
        isReleasedWhenClosed = false
        titlebarAppearsTransparent = true
        titleVisibility = .visible
        isMovableByWindowBackground = true
        
        setCenter(offset: size)
    }
}
