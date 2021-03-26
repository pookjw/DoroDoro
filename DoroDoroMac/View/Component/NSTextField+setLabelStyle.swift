//
//  NSTextField+setLabelStyle.swift
//  DoroDoroMac
//
//  Created by Jinwoo Kim on 3/26/21.
//

import Cocoa

extension NSTextField {
    internal func setLabelStyle() {
        isEditable = false
        isSelectable = false
        maximumNumberOfLines = 0
        isBezeled = false
        drawsBackground = false
        preferredMaxLayoutWidth = 0
        lineBreakMode = .byWordWrapping
    }
}
