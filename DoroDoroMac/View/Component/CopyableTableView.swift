//
//  CopyableTableView.swift
//  DoroDoroMac
//
//  Created by Jinwoo Kim on 3/24/21.
//

import Cocoa
import Combine

internal final class CopyableTableView: NSTableView {
    internal let copyEvent: PassthroughSubject<NSMenuItem, Never> = .init()
    
    @objc private func copy(_ sender: NSMenuItem) {
        copyEvent.send(sender)
    }
}
