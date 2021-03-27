//
//  SearchHeaderItem.swift
//  DoroDoroMac
//
//  Created by Jinwoo Kim on 3/27/21.
//

import Foundation

internal final class SearchHeaderItem: NSObject {
    internal private(set) var title: String?
    
    internal convenience init(title: String) {
        self.init()
        self.title = title
    }
    
    private let id: UUID = .init()
    
    internal override func isEqual(_ object: Any?) -> Bool {
        guard let object: SearchHeaderItem = object as? SearchHeaderItem else {
            return false
        }
        return self.id == object.id
    }
}
