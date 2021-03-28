//
//  HardwareService.swift
//  DoroDoroMac
//
//  Created by Jinwoo Kim on 3/29/21.
//

import Foundation
import IOKit

internal final class HardwareService {
    internal static let shared: HardwareService = .init()
    
    // https://stackoverflow.com/a/50008492
    internal var modelName: String? {
        let service = IOServiceGetMatchingService(kIOMasterPortDefault,
                                                  IOServiceMatching("IOPlatformExpertDevice"))
        var modelIdentifier: String?
        if let modelData = IORegistryEntryCreateCFProperty(service, "model" as CFString, kCFAllocatorDefault, 0).takeRetainedValue() as? Data {
            modelIdentifier = String(data: modelData, encoding: .utf8)?.trimmingCharacters(in: .controlCharacters)
        }
        
        IOObjectRelease(service)
        return modelIdentifier
    }
}
