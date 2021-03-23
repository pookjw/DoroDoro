//
//  UndoableSearchField.swift
//  DoroDoroMac
//
//  Created by Jinwoo Kim on 3/24/21.
//

import Cocoa

internal final class UndoableSearchField: NSSearchField {
    internal convenience init() {
        self.init(frame: .zero)
        registerUndoManger()
    }

    override func textDidChange(_ notification: Notification) {
        super.textDidChange(notification)
        registerUndoManger()
    }

    @objc private func undo(_ previous: String) {
        stringValue = previous
    }

    @objc private func undoFromMenu(_ sender: NSMenuItem) {
        undoManager?.undo()
    }

    @objc private func redoFromMenu(_ sender: NSMenuItem) {
        undoManager?.redo()
    }

    private func registerUndoManger() {
        undoManager?.registerUndo(withTarget: self, selector: #selector(undo(_:)), object: stringValue)
    }
}

extension UndoableSearchField: NSMenuItemValidation {
    internal func validateMenuItem(_ menuItem: NSMenuItem) -> Bool {
        guard let undoManager: UndoManager = undoManager,
            let customMenu: CustomMenu = NSApp.mainMenu as? CustomMenu else {
            return false
        }

        if customMenu.isUndoMenuItem(menuItem) {
            return undoManager.canUndo
        } else if customMenu.isRedoMenuItem(menuItem) {
            return undoManager.canRedo
        } else {
            return false
        }
    }
}
