//
//  SearchHeaderItem.swift
//  DoroDoro
//
//  Created by Jinwoo Kim on 2/28/21.
//

import Foundation

public struct SearchHeaderItem: Hashable {
    public var title: String
    
    public let id = UUID()
    
    public static func == (lhs: SearchHeaderItem, rhs: SearchHeaderItem) -> Bool {
        return lhs.id == rhs.id
    }
}
