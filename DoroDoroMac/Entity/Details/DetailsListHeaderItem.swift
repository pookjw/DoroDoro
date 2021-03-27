//
//  DetailsListHeaderItem.swift
//  DoroDoroMac
//
//  Created by Jinwoo Kim on 3/27/21.
//

import Foundation

internal final class DetailsListHeaderItem: NSObject {
    private let id: UUID = .init()
    
    internal override func isEqual(_ object: Any?) -> Bool {
        guard let object: DetailsListHeaderItem = object as? DetailsListHeaderItem else {
            return false
        }
        return self.id == object.id
    }
}
