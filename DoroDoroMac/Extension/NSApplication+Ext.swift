//
//  NSApplication+Ext.swift
//  DoroDoroMac
//
//  Created by Jinwoo Kim on 3/14/21.
//

import Cocoa

extension NSApplication {
    internal var isDarkAquaMode: Bool {
        return effectiveAppearance.isDarkAquaMode
    }
    
    internal var applicationName: String {
        return ProcessInfo.processInfo.processName
    }
}
