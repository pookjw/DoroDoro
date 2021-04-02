//
//  URLGuideHeaderItem.swift
//  DoroDoro
//
//  Created by Jinwoo Kim on 4/2/21.
//

import Foundation

internal struct URLGuideHeaderItem: Hashable, Equatable {
    internal enum HeaderType: Int {
        case search
        case searchWithText
        case searchCurrentLocation
        case bookmarks
    }
    internal let headerType: HeaderType
    
    internal static func == (lhs: URLGuideHeaderItem, rhs: URLGuideHeaderItem) -> Bool {
        return lhs.id == rhs.id
    }
    
    private let id: UUID = .init()
}
