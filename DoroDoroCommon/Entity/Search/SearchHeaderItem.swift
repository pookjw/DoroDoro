//
//  SearchHeaderItem.swift
//  DoroDoro
//
//  Created by Jinwoo Kim on 2/28/21.
//

import Foundation

internal struct SearchHeaderItem: Hashable, Equatable {
    internal var title: String
    
    internal static func == (lhs: SearchHeaderItem, rhs: SearchHeaderItem) -> Bool {
        return lhs.id == rhs.id
    }
    
    private let id: UUID = .init()
}
