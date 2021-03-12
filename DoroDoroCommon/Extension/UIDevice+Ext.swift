//
//  UIDevice+Ext.swift
//  DoroDoro
//
//  Created by Jinwoo Kim on 3/8/21.
//

import UIKit

extension UIDevice {
    internal static var modelName: String {
        var systemInfo = utsname()
        uname(&systemInfo)
        let machineMirror = Mirror(reflecting: systemInfo.machine)
        let identifier = machineMirror.children.reduce("") { identifier, element in
            guard let value = element.value as? Int8, value != 0 else { return identifier }
            return identifier + String(UnicodeScalar(UInt8(value)))
        }
        return identifier
    }
}
