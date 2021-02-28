//
//  NSObject+Ext.swift
//  DoroDoro
//
//  Created by Jinwoo Kim on 3/1/21.
//

import UIKit

extension NSObject {
    internal func printDeinitMessage() {
        print("deinit: \(String(describing: self))")
    }
}
