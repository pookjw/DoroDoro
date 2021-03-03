//
//  SettingsData.swift
//  DoroDoro
//
//  Created by Jinwoo Kim on 3/4/21.
//

import Foundation

internal struct SettingsData {
    internal var enabledCloudService: Bool = false
    
    internal init() {}
    
    internal init(dic: [String: Any]) {
        if let enabledCloudServiceKey: Bool = dic[Constants.enabledCloudServiceKey] as? Bool {
            self.enabledCloudService = enabledCloudServiceKey
        }
    }
    
    internal func convertToDic() -> [String: Any] {
        var dic: [String: Any] = [:]
        dic[Constants.enabledCloudServiceKey] = enabledCloudService
        return dic
    }
    
    private struct Constants {
        static fileprivate let enabledCloudServiceKey: String = "enabled_cloud_service"
    }
}

extension SettingsData: Equatable {
    static internal func ==(lhs: SettingsData, rhs: SettingsData) -> Bool {
        return (lhs.enabledCloudService == rhs.enabledCloudService)
    }
}
