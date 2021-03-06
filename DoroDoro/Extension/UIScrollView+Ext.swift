//
//  UIScrollView+Ext.swift
//  DoroDoro
//
//  Created by Jinwoo Kim on 3/7/21.
//

import UIKit

extension UIScrollView {
    internal func scrollToTop(animated: Bool) {
        let offset = CGPoint(
            x: -adjustedContentInset.left,
            y: -adjustedContentInset.top)

        setContentOffset(offset, animated: animated)
   }
}
