//
//  URLGuideCellItem.swift
//  DoroDoro
//
//  Created by Jinwoo Kim on 4/2/21.
//

import Foundation

internal struct URLGuideCellItem: Hashable, Equatable {
    internal enum CellType: String {
        case search = "dorodoro://?search"
        case searchWithText = "dorodoro://?search=kelly"
        case searchCurrentLocation = "dorodoro://?searchCurrentLocation"
        case bookmarks = "dorodoro://?bookmarks"
    }
    internal let cellType: CellType
    
    internal static func == (lhs: URLGuideCellItem, rhs: URLGuideCellItem) -> Bool {
        return lhs.id == rhs.id
    }
    
    private let id: UUID = .init()
}
