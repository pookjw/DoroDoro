//
//  DetailHeaderItem.swift
//  DoroDoro
//
//  Created by Jinwoo Kim on 3/1/21.
//

import Foundation

internal struct DetailHeaderItem: Hashable, Equatable {
    internal enum HeaderType: Int {
        case link = 0
        case eng = 1
        case map = 2
    }
    
    internal let headerType: HeaderType
    
    internal static func == (lhs: DetailHeaderItem, rhs: DetailHeaderItem) -> Bool {
        return lhs.id == rhs.id
    }
    
    private let id: UUID = .init()
}
