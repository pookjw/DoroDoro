//
//  AboutWindow.swift
//  DoroDoroMac
//
//  Created by Jinwoo Kim on 3/22/21.
//

import Cocoa

internal final class AboutWindow: NSWindow {
    internal convenience init() {
        self.init(contentRect: .zero,
                  styleMask:  [.closable, .titled],
                  backing: .buffered,
                  defer: false)
        let size: NSSize = .init(width: 400, height: 400)
        let aboutVC: AboutViewController = .init()
        aboutVC.preferredContentSize = size
        
        contentViewController = aboutVC
        titleVisibility = .visible
        title = "정보 (번역)"
        isReleasedWhenClosed = false
        
        setCenter(offset: size)
    }
}
