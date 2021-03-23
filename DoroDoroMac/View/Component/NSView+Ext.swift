//
//  NSView+Ext.swift
//  DoroDoroMac
//
//  Created by Jinwoo Kim on 3/24/21.
//

import Cocoa

extension NSView {
    class func fromNib() -> Self? {
        var topLevelObjects: NSArray? = .init()
        Bundle.main.loadNibNamed(String(describing: Self.self), owner: self, topLevelObjects: &topLevelObjects)
        let views = (topLevelObjects! as Array).filter { $0 is NSView }
        return views[0] as? Self
    }
}
