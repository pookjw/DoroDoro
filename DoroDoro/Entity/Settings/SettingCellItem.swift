//
//  SettingCellItem.swift
//  DoroDoro
//
//  Created by Jinwoo Kim on 3/4/21.
//

import Foundation

internal struct SettingCellItem: Hashable, Equatable {
    internal enum CellType: Hashable {
        case mapSelection(mapType: SettingsMapSelectionType, selected: Bool)
        case contributor(contributorType: SettingsContributorType, url: String)
        case acknowledgements
        case appinfo(version: String?, build: String?)
    }
    internal let cellType: CellType
    
    internal static func == (lhs: SettingCellItem, rhs: SettingCellItem) -> Bool {
        return lhs.id == rhs.id
    }
    
    private let id: UUID = .init()
}
