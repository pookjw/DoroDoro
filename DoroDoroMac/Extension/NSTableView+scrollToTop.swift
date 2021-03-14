//
//  NSTableView+scrollToTop.swift
//  DoroDoroMac
//
//  Created by Jinwoo Kim on 3/14/21.
//

import Cocoa

extension NSTableView {
    internal func scrollToTop() {
        guard let headerViewHeight: CGFloat = headerView?.frame.height else {
            scroll(.zero)
            return
        }
        scroll(CGPoint(x: 0, y: -headerViewHeight))
    }
}
