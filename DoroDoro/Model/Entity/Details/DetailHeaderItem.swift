//
//  DetailHeaderItem.swift
//  DoroDoro
//
//  Created by Jinwoo Kim on 3/1/21.
//

import Foundation

internal struct DetailHeaderItem: Hashable, Equatable {
    internal enum ItemType: String {
        case link = "세부정보"
        case eng = "영문주소"
        case coord = "지도"
    }
    
    internal let itemType: ItemType
    internal let id = UUID()
    
    internal static func == (lhs: DetailHeaderItem, rhs: DetailHeaderItem) -> Bool {
        return lhs.id == rhs.id
    }
}
