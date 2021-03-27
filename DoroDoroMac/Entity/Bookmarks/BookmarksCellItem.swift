//
//  BookmarksCellItem.swift
//  DoroDoroMac
//
//  Created by Jinwoo Kim on 3/27/21.
//

import Foundation

internal final class BookmarksCellItem: NSObject {
    internal private(set) var roadAddr: String? = nil
    
    internal convenience init(roadAddr: String) {
        self.init()
        self.roadAddr = roadAddr
    }
    
    internal override func isEqual(_ object: Any?) -> Bool {
        guard let object: BookmarksCellItem = object as? BookmarksCellItem else {
            return false
        }
        guard let lhsRoadAddr: String = self.roadAddr,
              let rhsRoadAddr: String = object.roadAddr else {
            return false
        }
        return lhsRoadAddr == rhsRoadAddr
    }
}
