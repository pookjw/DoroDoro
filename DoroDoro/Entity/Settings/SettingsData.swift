//
//  SettingsData.swift
//  DoroDoro
//
//  Created by Jinwoo Kim on 3/4/21.
//

import Foundation

internal struct SettingsData {
    internal var mapSelection: MapSelection = .appleMap
    
    internal init() {}
    
    internal init(dic: [String: Any]) {
        if let mapSelectionRawValue: Int = dic[Constants.mapSelectionKey] as? Int,
           let mapSelection: MapSelection = MapSelection(rawValue: mapSelectionRawValue) {
            self.mapSelection = mapSelection
        }
    }
    
    internal func convertToDic() -> [String: Any] {
        var dic: [String: Any] = [:]
        dic[Constants.mapSelectionKey] = mapSelection.rawValue
        return dic
    }
    
    private struct Constants {
        static fileprivate let mapSelectionKey: String = "map_selection"
    }
}

extension SettingsData: Equatable {
    static internal func ==(lhs: SettingsData, rhs: SettingsData) -> Bool {
        return (lhs.mapSelection == rhs.mapSelection)
    }
}
