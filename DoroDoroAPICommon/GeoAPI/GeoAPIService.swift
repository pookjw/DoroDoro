//
//  GeoAPIService.swift
//  DoroDoro
//
//  Created by Jinwoo Kim on 3/7/21.
//

import Foundation
import CoreLocation
import Combine

final public class GeoAPIService: NSObject {
    static public let shared: GeoAPIService = .init()
    public let coordEvent: PassthroughSubject<(latitude: Double, longitude: Double), Never> = .init()
    public let coordErrorEvent: PassthroughSubject<Error, Never> = .init()
    
    public override init() {
        super.init()
        locationManager.delegate = self
    }
    
    public func requestCurrentCoord() {
        locationManager.requestWhenInUseAuthorization()
        locationManager.requestLocation()
    }
    
    private let locationManager: CLLocationManager = .init()
}

extension GeoAPIService: CLLocationManagerDelegate {
    public func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        guard let location: CLLocation = locations.first else {
            coordErrorEvent.send(GeoAPIError.noLocationFound)
            return
        }
        
        let result: (latitude: Double, longitude: Double) = {
            let latitude: Double = location.coordinate.latitude
            let longtitude: Double = location.coordinate.longitude
            return (latitude, longtitude)
        }()
        
        coordEvent.send(result)
        manager.stopUpdatingLocation()
    }
    
    public func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        coordErrorEvent.send(error)
    }
}
