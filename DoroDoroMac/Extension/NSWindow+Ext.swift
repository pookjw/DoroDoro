//
//  NSWindow+Ext.swift
//  DoroDoroMac
//
//  Created by Jinwoo Kim on 3/22/21.
//

import Cocoa

extension NSWindow {
    internal func setCenter(offset size: NSSize = .zero) {
        if let screenRect: NSRect = NSScreen.main?.frame {
            let center: NSPoint = .init(x: screenRect.midX - (size.width / 2),
                                        y: screenRect.midY - (size.height / 2))
            setFrameOrigin(center)
        }
    }
}
