//
//  DetailResultItem.swift
//  DoroDoro
//
//  Created by Jinwoo Kim on 3/1/21.
//

import Foundation

internal struct DetailResultItem: Hashable, Equatable {
    internal enum ResultType: Hashable {
        case link(text: String, secondaryText: String)
        case eng(text: String, secondaryText: String)
        case map(latitude: Double, longitude: Double, locationTitle: String)
    }
    internal let resultType: ResultType
    
    internal static func == (lhs: DetailResultItem, rhs: DetailResultItem) -> Bool {
        return lhs.id == rhs.id
    }
    
    private let id: UUID = .init()
}
