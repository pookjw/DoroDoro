//
//  GeoAPIService.swift
//  DoroDoro
//
//  Created by Jinwoo Kim on 3/7/21.
//

import Foundation
import CoreLocation
import Combine

public final class GeoAPIService: NSObject {
    public static let shared: GeoAPIService = .init()
    public let coordEvent: PassthroughSubject<(latitude: Double, longitude: Double), Never> = .init()
    public let coordErrorEvent: PassthroughSubject<Error, Never> = .init()
    
    public override init() {
        super.init()
        locationManager.delegate = self
    }
    
    public func requestCurrentCoord() {
        // 권한을 거부당했을 경우 에러만 날린다.
        guard locationManager.authorizationStatus != .denied && locationManager.authorizationStatus != .restricted else {
            coordErrorEvent.send(GeoAPIError.permissionDenined)
            return
        }
        
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
        // 권한 에러일 경우
        if let clerror: CLError = error as? CLError, clerror.code == .denied {
            switch manager.authorizationStatus {
            case .notDetermined:
                // 아직 권한이 결정되지 않은 상태에서는 경고 에러를 날린다.
                coordErrorEvent.send(GeoAPIError.warnAllowPermission)
                return
            case .denied, .restricted:
                coordErrorEvent.send(GeoAPIError.permissionDenined)
                return
            default:
                // 권한이 결정됐는데 에러가 발생했을 경우는 에러를 날린다.
                break
            }
        }
        
        coordErrorEvent.send(error)
    }
}
