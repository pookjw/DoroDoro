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
    internal let title: String
    
    internal func makeContentView() -> UIView & UIContentView {
        return _DetailsMapViewContentView(configuration: self)
    }
    
    internal func updated(for state: UIConfigurationState) -> Self {
        return self
    }
}

final fileprivate class _DetailsMapViewContentView: UIView, UIContentView {
    private weak var mapView: MKMapView? = nil
    
    fileprivate var configuration: UIContentConfiguration {
        didSet {
            if mapView == nil {
                configureMapView()
            }
            updateConfiguration()
        }
    }
    
    fileprivate init(configuration: UIContentConfiguration) {
        self.configuration = configuration
        super.init(frame: .zero)
    }
    
    required fileprivate init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configureMapView() {
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
        mapView.isScrollEnabled = false
        mapView.isPitchEnabled = false
        mapView.isZoomEnabled = false
        mapView.isRotateEnabled = false
    }
    
    private func updateConfiguration() {
        guard let mapView: MKMapView = mapView else {
            return
        }
        
        guard let configuration: DetailsMapViewConfiguration = configuration as? DetailsMapViewConfiguration else {
             return
        }
        
        let coordinate: CLLocationCoordinate2D = .init(latitude: configuration.latitude, longitude: configuration.longitude)
        let region: MKCoordinateRegion = .init(center: coordinate, latitudinalMeters: 300, longitudinalMeters: 300)
        mapView.setRegion(mapView.regionThatFits(region), animated: false)
        
        mapView.removeAnnotations(mapView.annotations)
        let annotation: MKPointAnnotation = .init()
        annotation.title = configuration.title
        annotation.coordinate = coordinate
        mapView.addAnnotation(annotation)
    }
}
