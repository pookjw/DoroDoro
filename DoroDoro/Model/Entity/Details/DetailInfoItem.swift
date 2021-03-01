//
//  DetailInfoItem.swift
//  DoroDoro
//
//  Created by Jinwoo Kim on 3/1/21.
//

import Foundation
import UIKit

internal struct DetailInfoItem: Hashable, Equatable {
    internal enum ItemType: Hashable {
        case link(String, String)
        case eng(String, String)
        case map(Double, Double)
    }
    internal let itemType: ItemType
    
    private let id = UUID()
    
    internal static func == (lhs: DetailInfoItem, rhs: DetailInfoItem) -> Bool {
        return lhs.id == rhs.id
    }
}
