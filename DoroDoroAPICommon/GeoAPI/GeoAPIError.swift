//
//  GeoAPIError.swift
//  DoroDoro
//
//  Created by Jinwoo Kim on 3/7/21.
//

import Foundation

public enum GeoAPIError: String, Error {
    case noLocationFound
    case warnAllowPermission
    case permissionDenined
}
