//
//  DetailsMapViewConfiguration.swift
//  DoroDoro
//
//  Created by Jinwoo Kim on 3/1/21.
//

import UIKit
import MapKit
import SnapKit

internal struct DetailsMapViewConfiguration: UIContentConfiguration {
    internal let latitude: Double
    internal let longitude: Double
    
    internal func makeContentView() -> UIView & UIContentView {
        return _DetailsMapViewContentView(configuration: self)
    }
    
    internal func updated(for state: UIConfigurationState) -> Self {
        return self
    }
}

final fileprivate class _DetailsMapViewContentView: UIView, UIContentView {
    private weak var mapView: MKMapView? = nil
    #if arch(arm64) || targetEnvironment(simulator)
    private weak var kakaoMapView: MTMapView? = nil
    #endif
    
    fileprivate var configuration: UIContentConfiguration {
        didSet {
            configure()
        }
    }
    
    fileprivate init(configuration: UIContentConfiguration) {
        self.configuration = configuration
        super.init(frame: .zero)
    }
    
    required fileprivate init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configure() {
        guard let configuration: DetailsMapViewConfiguration = configuration as? DetailsMapViewConfiguration else {
             return
        }
        
        #if arch(arm64) || targetEnvironment(simulator)
        let kakaoMapView: MTMapView = .init()
        self.kakaoMapView = kakaoMapView
        addSubview(kakaoMapView)
        kakaoMapView.translatesAutoresizingMaskIntoConstraints = false
        if superview != nil {
            translatesAutoresizingMaskIntoConstraints = false
            
            snp.remakeConstraints { make in
                make.edges.equalToSuperview()
                make.height.equalTo(300).priority(999)
            }
            
            kakaoMapView.snp.remakeConstraints { make in
                make.edges.equalToSuperview()
                
            }
        } else {
            kakaoMapView.snp.remakeConstraints { make in
                make.edges.equalToSuperview()
                make.height.equalTo(300).priority(999)
            }
        }
        
        kakaoMapView.isUserInteractionEnabled = false
        
        let mapPoint: MTMapPoint = .init(geoCoord: MTMapPointGeo(latitude: configuration.latitude, longitude: configuration.longitude))
        kakaoMapView.setMapCenter(mapPoint, zoomLevel: 4, animated: false)
        
        #else
        let mapView: MKMapView = .init()
        self.mapView = mapView
        addSubview(mapView)
        mapView.translatesAutoresizingMaskIntoConstraints = false
        if superview != nil {
            translatesAutoresizingMaskIntoConstraints = false
            
            snp.remakeConstraints { make in
                make.edges.equalToSuperview()
                make.height.equalTo(300).priority(999)
            }
            
            mapView.snp.remakeConstraints { make in
                make.edges.equalToSuperview()
                
            }
        } else {
            mapView.snp.remakeConstraints { make in
                make.edges.equalToSuperview()
                make.height.equalTo(300).priority(999)
            }
        }
        
        mapView.isUserInteractionEnabled = false
        
        let coordinate: CLLocationCoordinate2D = .init(latitude: configuration.latitude, longitude: configuration.longitude)
        let region: MKCoordinateRegion = .init(center: coordinate, latitudinalMeters: 3000, longitudinalMeters: 3000)
        mapView.setRegion(mapView.regionThatFits(region), animated: false)
        #endif
    }
}
