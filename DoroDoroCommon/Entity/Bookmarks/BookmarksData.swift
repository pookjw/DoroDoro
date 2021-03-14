//
//  BookmarksData.swift
//  DoroDoro
//
//  Created by Jinwoo Kim on 3/4/21.
//

import Foundation

internal struct BookmarksData {
    internal var bookmarkedRoadAddrs: [String: Date] = [:]
    
    internal init() {}
    
    internal init(dic: [String: Date]) {
        self.bookmarkedRoadAddrs = dic
    }
}

extension BookmarksData: Equatable {
    internal static func ==(lhs: BookmarksData, rhs: BookmarksData) -> Bool {
        return (lhs.bookmarkedRoadAddrs == rhs.bookmarkedRoadAddrs)
    }
}
