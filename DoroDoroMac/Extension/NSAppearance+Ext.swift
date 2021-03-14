//
//  NSAppearance+Ext.swift
//  DoroDoroMac
//
//  Created by Jinwoo Kim on 3/14/21.
//

import Cocoa

extension NSAppearance {
    internal var isDarkAquaMode: Bool {
        return bestMatch(from: [.darkAqua, .aqua]) == .darkAqua
    }
}
