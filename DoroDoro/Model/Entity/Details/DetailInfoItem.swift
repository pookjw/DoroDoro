//
//  DetailInfoItem.swift
//  DoroDoro
//
//  Created by Jinwoo Kim on 3/1/21.
//

import Foundation
import UIKit

internal struct DetailInfoItem: Hashable, Equatable {
    internal let title: String
    internal let subTitle: String
    
    private let id = UUID()
    
    internal static func == (lhs: DetailInfoItem, rhs: DetailInfoItem) -> Bool {
        return lhs.id == rhs.id
    }
}
