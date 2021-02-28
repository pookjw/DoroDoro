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
        let mapView: MKMapView = .init()
        self.mapView = mapView
        addSubview(mapView)
        mapView.translatesAutoresizingMaskIntoConstraints = false
        
        if superview != nil {
            translatesAutoresizingMaskIntoConstraints = false
            
            snp.remakeConstraints { make in
                make.edges.equalToSuperview()
                make.height.equalTo(300)
            }
            
            mapView.snp.remakeConstraints { make in
                make.edges.equalToSuperview()
                
            }
        } else {
            mapView.snp.remakeConstraints { make in
                make.edges.equalToSuperview()
                make.height.equalTo(300)
            }
        }
        
        if let configuration: DetailsMapViewConfiguration = configuration as? DetailsMapViewConfiguration {
//            mapView.centerCoordinate = CLLocationCoordinate2D(latitude: configuration.latitude, longitude: configuration.longitude)
        }
    }
}
