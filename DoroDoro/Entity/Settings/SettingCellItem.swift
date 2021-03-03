//
//  SettingCellItem.swift
//  DoroDoro
//
//  Created by Jinwoo Kim on 3/4/21.
//

import Foundation

internal struct SettingCellItem: Hashable, Equatable {
    internal enum CellType: Hashable {
        case mapSelection(mapType: MapSelection, selected: Bool)
    }
    internal let cellType: CellType
    
    internal static func == (lhs: SettingCellItem, rhs: SettingCellItem) -> Bool {
        return lhs.id == rhs.id
    }
    
    private let id: UUID = .init()
}
