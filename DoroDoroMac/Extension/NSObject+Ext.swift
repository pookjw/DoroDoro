//
//  NSObject+Ext.swift
//  DoroDoroMac
//
//  Created by Jinwoo Kim on 3/14/21.
//

import Foundation

extension NSObject {
    internal var className: String {
        return String(describing: type(of: self))
    }
    
    internal class var className: String {
        return String(describing: self)
    }
}
