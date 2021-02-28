//
//  SearchResultItem.swift
//  DoroDoro
//
//  Created by Jinwoo Kim on 2/28/21.
//

import Foundation

internal struct SearchResultItem: Hashable {
    internal let title: String
    private let id = UUID()
    
    internal static func == (lhs: SearchResultItem, rhs: SearchResultItem) -> Bool {
        return lhs.id == rhs.id
    }
}
