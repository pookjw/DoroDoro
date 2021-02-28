//
//  DetailMapItem.swift
//  DoroDoro
//
//  Created by Jinwoo Kim on 3/1/21.
//

import Foundation

internal struct DetailMapItem: Hashable, Equatable {
    internal let latitude: Double
    internal let longitude: Double
    
    internal let id = UUID()
    internal static func == (lhs: DetailMapItem, rhs: DetailMapItem) -> Bool {
        return lhs.id == rhs.id
    }
}
