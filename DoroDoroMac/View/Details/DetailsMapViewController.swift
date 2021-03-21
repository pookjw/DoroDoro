//
//  DetailsMapViewController.swift
//  DoroDoroMac
//
//  Created by Jinwoo Kim on 3/21/21.
//

import Cocoa
import MapKit
import SnapKit

internal final class DetailsMapViewController: NSViewController {
    internal var (latitude, longitude): (Double, Double) = (37.5765916191985, 126.974974825074)
    internal var locationTitle: String = "서울 종로구 효자로 12"
    
    private weak var mapView: MKMapView? = nil
    private weak var openInAppleMapsAppButton: NSButton? = nil

    internal override func loadView() {
        let view: NSView = .init()
        self.view = view
    }
    
    internal override func viewDidLoad() {
        super.viewDidLoad()
        configureMapView()
        configureOpenInAppleMapsAppButton()
    }
    
    private func configureMapView() {
        let mapView: MKMapView = .init()
        self.mapView = mapView
        view.addSubview(mapView)
        mapView.translatesAutoresizingMaskIntoConstraints = false
        mapView.snp.remakeConstraints { make in
            make.top.equalToSuperview()
            make.leading.equalToSuperview()
            make.trailing.equalToSuperview()
        }
        
        //
        
        let coordinate: CLLocationCoordinate2D = .init(latitude: latitude, longitude: longitude)
        let region: MKCoordinateRegion = .init(center: coordinate, latitudinalMeters: 300, longitudinalMeters: 300)
        mapView.setRegion(mapView.regionThatFits(region), animated: false)
        mapView.removeAnnotations(mapView.annotations)
        let annotation: MKPointAnnotation = .init()
        annotation.title = locationTitle
        annotation.coordinate = coordinate
        mapView.addAnnotation(annotation)
    }
    
    private func configureOpenInAppleMapsAppButton() {
        let openInAppleMapsAppButton: NSButton = .init()
        self.openInAppleMapsAppButton = openInAppleMapsAppButton
        view.addSubview(openInAppleMapsAppButton)
        openInAppleMapsAppButton.translatesAutoresizingMaskIntoConstraints = false
        openInAppleMapsAppButton.snp.remakeConstraints { [weak mapView] make in
            guard let mapView: MKMapView = mapView else {
                return
            }
            make.top.equalTo(mapView.snp.bottom)
            make.leading.equalToSuperview()
            make.trailing.equalToSuperview()
            make.bottom.equalToSuperview()
        }
        
        openInAppleMapsAppButton.setButtonType(.accelerator)
        openInAppleMapsAppButton.title = Localizable.OPEN_IN_APPLE_MAPS_APP.string
        openInAppleMapsAppButton.action = #selector(openInAppleMapsApp(_:))
        openInAppleMapsAppButton.target = self
    }
    
    @objc private func openInAppleMapsApp(_ sender: Any) {
        let placemark: MKPlacemark = .init(coordinate: CLLocationCoordinate2D(latitude: latitude, longitude: longitude))
        let mapItem: MKMapItem = .init(placemark: placemark)
        mapItem.openInMaps(launchOptions: nil)
    }
}
