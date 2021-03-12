//
//  SettingsData.swift
//  DoroDoro
//
//  Created by Jinwoo Kim on 3/4/21.
//

import Foundation

internal struct SettingsData {
    internal var mapSelection: SettingsMapSelectionType = .appleMaps
    
    internal init() {}
    
    internal init(dic: [String: Any]) {
        if let mapSelectionRawValue: Int = dic[Constants.mapSelectionKey] as? Int,
           let mapSelection: SettingsMapSelectionType = SettingsMapSelectionType(rawValue: mapSelectionRawValue) {
            self.mapSelection = mapSelection
        }
    }
    
    internal func convertToDic() -> [String: Any] {
        var dic: [String: Any] = [:]
        dic[Constants.mapSelectionKey] = mapSelection.rawValue
        return dic
    }
    
    private struct Constants {
        fileprivate static let mapSelectionKey: String = "map_selection"
    }
}

extension SettingsData: Equatable {
    internal static func ==(lhs: SettingsData, rhs: SettingsData) -> Bool {
        return (lhs.mapSelection == rhs.mapSelection)
    }
}
