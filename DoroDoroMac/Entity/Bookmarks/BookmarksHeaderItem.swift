//
//  BookmarksHeaderItem.swift
//  DoroDoroMac
//
//  Created by Jinwoo Kim on 3/27/21.
//

import Foundation

internal final class BookmarksHeaderItem: NSObject {
    private let id: UUID = .init()
    
    internal override func isEqual(_ object: Any?) -> Bool {
        guard let object: BookmarksHeaderItem = object as? BookmarksHeaderItem else {
            return false
        }
        return self.id == object.id
    }
}
