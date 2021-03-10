//
//  GeoAPIError+LocalizedError.swift
//  DoroDoro
//
//  Created by Jinwoo Kim on 3/11/21.
//

import Foundation
#if os(watchOS)
import DoroDoroWatchAPI
#else
import DoroDoroAPI
#endif

extension GeoAPIError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .noLocationFound:
            return Localizable.GEO_API_ERROR_NO_LOCATION_FOUND.string
        case .permissionDenined:
            return Localizable.GEO_API_ERROR_PERMISSION_DENINED.string
        case .warnAllowPermission:
            return Localizable.GEO_API_WARN_ALLOW_PERMISSON.string
        default:
            return self.rawValue
        }
    }
}
