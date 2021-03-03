//
//  BookmarksCellItem.swift
//  DoroDoro
//
//  Created by Jinwoo Kim on 3/4/21.
//

import Foundation

internal struct BookmarksCellItem: Hashable, Equatable {
    internal let roadAddr: String
    
    internal static func == (lhs: BookmarksCellItem, rhs: BookmarksCellItem) -> Bool {
        return lhs.id == rhs.id
    }
    
    private let id: UUID = .init()
}
