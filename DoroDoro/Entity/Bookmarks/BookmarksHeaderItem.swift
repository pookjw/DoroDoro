//
//  BookmarksHeaderItem.swift
//  DoroDoro
//
//  Created by Jinwoo Kim on 3/4/21.
//

import Foundation

internal struct BookmarksHeaderItem: Hashable, Equatable {
    internal static func == (lhs: BookmarksHeaderItem, rhs: BookmarksHeaderItem) -> Bool {
        return lhs.id == rhs.id
    }
    
    private let id: UUID = .init()
}
