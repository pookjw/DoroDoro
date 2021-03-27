//
//  DetailsMapResultItem.swift
//  DoroDoroMac
//
//  Created by Jinwoo Kim on 3/20/21.
//

import Foundation

internal final class DetailsMapResultItem: NSObject {
    internal private(set) var latitude: Double?
    internal private(set) var longitude: Double?
    internal private(set) var locationTitle: String?
    
    internal convenience init(latitude: Double, longitude: Double, locationTitle: String) {
        self.init()
        self.latitude = latitude
        self.longitude = longitude
        self.locationTitle = locationTitle
    }
}
