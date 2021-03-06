//
//  UIView+Ext.swift
//  DoroDoro
//
//  Created by Jinwoo Kim on 3/7/21.
//

import UIKit

extension UIView {
    internal func getSafeAreaInsets() -> UIEdgeInsets {
        guard let superview = superview else { return .zero }
        return superview.safeAreaInsets
    }
}
