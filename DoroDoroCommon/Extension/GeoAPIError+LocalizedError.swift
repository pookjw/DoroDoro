//
//  GeoAPIError+LocalizedError.swift
//  DoroDoro
//
//  Created by Jinwoo Kim on 3/11/21.
//

import Foundation
#if os(watchOS)
import DoroDoroWatchAPI
#elseif os(tvOS)
import DoroDoroTVAPI
#elseif os(macOS)
import DoroDoroMacAPI
#else
import DoroDoroAPI
#endif

extension GeoAPIError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .noLocationFound:
            return Localizable.GEO_API_ERROR_NO_LOCATION_FOUND.string
        case .permissionDenined:
            #if os(iOS)
            return Localizable.GEO_API_ERROR_PERMISSION_DENINED_IOS.string
            #else
            return Localizable.GEO_API_ERROR_PERMISSION_DENINED.string
            #endif
        case .warnAllowPermission:
            return Localizable.GEO_API_WARN_ALLOW_PERMISSON.string
        default:
            return self.rawValue
        }
    }
}
