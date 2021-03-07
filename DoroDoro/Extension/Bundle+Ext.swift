//
//  Bundle+Ext.swift
//  DoroDoro
//
//  Created by Jinwoo Kim on 3/7/21.
//

import Foundation

extension Bundle {
    internal var releaseVersionNumber: String {
        return (infoDictionary?["CFBundleShortVersionString"] as? String) ?? Localizable.UNKNOWN.string
    }
    
    internal var buildVersionNumber: String {
        return (infoDictionary?["CFBundleVersion"] as? String) ?? Localizable.UNKNOWN.string
    }
}
