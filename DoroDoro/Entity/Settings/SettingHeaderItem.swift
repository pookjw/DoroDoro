//
//  SettingHeaderItem.swift
//  DoroDoro
//
//  Created by Jinwoo Kim on 3/4/21.
//

import Foundation

internal struct SettingHeaderItem: Hashable, Equatable {
    internal enum HeaderType: Int {
        case map = 0
        case about
        case contributor
    }
    
    internal let headerType: HeaderType
    
    internal static func == (lhs: SettingHeaderItem, rhs: SettingHeaderItem) -> Bool {
        return lhs.id == rhs.id
    }
    
    private let id: UUID = .init()
}
