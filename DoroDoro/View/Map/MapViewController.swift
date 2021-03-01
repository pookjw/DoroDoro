//
//  MapViewController.swift
//  DoroDoro
//
//  Created by Jinwoo Kim on 3/1/21.
//

import UIKit
import MapKit
import SnapKit

final internal class MapViewController: UIViewController {
    internal enum MapType {
        case apple, kakao
    }
    
    internal var mapType: MapType = .kakao
    internal var locationTitle: String? = nil
    
    // 서울 종로구 효자로 12
    internal var (latitude, longitude): (Double, Double) = (37.5765916191985, 126.974974825074)
    
    private weak var mapView: MKMapView? = nil
    #if arch(arm64) || targetEnvironment(simulator)
    private weak var kakaoMapView: MTMapView? = nil
    #endif
    private weak var doneBarButtonItem: UIBarButtonItem? = nil
    private weak var openMapAppBarButtonItem: UIBarButtonItem? = nil
    
    override internal func viewDidLoad() {
        super.viewDidLoad()
        
        configureAttributes()
        
        switch mapType {
        case .apple:
            configureAppleMapView()
        case .kakao:
            #if arch(arm64) || targetEnvironment(simulator)
            configureKakaoMapView()
            #else
            configureAppleMapView()
            #endif
        }
    }
    
    private func configureAttributes() {
        title = Localizable.MAP_VIEW_CONTROLLER_TITLE.string
        
        //
        
        let doneBarButtonItem: UIBarButtonItem = .init(title: Localizable.DONE.string,
                                                       image: nil,
                                                       primaryAction: getDismissAction(),
                                                       menu: nil)
        self.doneBarButtonItem = doneBarButtonItem
        navigationItem.rightBarButtonItems = [doneBarButtonItem]
        
        let openMapAppBarButtonItem: UIBarButtonItem = .init(title: nil,
                                                             image: UIImage(systemName: "map"),
                                                             primaryAction: getOpenMapAppAction(),
                                                             menu: nil)
        self.openMapAppBarButtonItem = openMapAppBarButtonItem
        navigationItem.leftBarButtonItems = [openMapAppBarButtonItem]
    }
    
    private func configureAppleMapView() {
        let mapView: MKMapView = .init()
        self.mapView = mapView
        view.addSubview(mapView)
        mapView.translatesAutoresizingMaskIntoConstraints = false

        mapView.snp.remakeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        let coordinate: CLLocationCoordinate2D = .init(latitude: latitude, longitude: longitude)
        let region: MKCoordinateRegion = .init(center: coordinate, latitudinalMeters: 300, longitudinalMeters: 300)
        mapView.setRegion(mapView.regionThatFits(region), animated: false)
        
        mapView.removeAnnotations(mapView.annotations)
        let annotation: MKPointAnnotation = .init()
        annotation.title = locationTitle
        annotation.coordinate = coordinate
        mapView.addAnnotation(annotation)
    }
    
    #if arch(arm64) || targetEnvironment(simulator)
    private func configureKakaoMapView() {
        let kakaoMapView: MTMapView = .init()
        self.kakaoMapView = kakaoMapView
        view.addSubview(kakaoMapView)
        kakaoMapView.translatesAutoresizingMaskIntoConstraints = false
        kakaoMapView.snp.remakeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        let geoCoord: MTMapPointGeo = .init(latitude: latitude, longitude: longitude)
        let mapPoint: MTMapPoint = .init(geoCoord: geoCoord)
        kakaoMapView.setMapCenter(mapPoint, zoomLevel: -2, animated: false)
        
        //
        
        let pointItem: MTMapPOIItem = .init()
        pointItem.markerType = .redPin
        pointItem.mapPoint = mapPoint
        if let locationtitle: String = locationTitle {
            pointItem.itemName = locationtitle
        }
        pointItem.showDisclosureButtonOnCalloutBalloon = false
        pointItem.markerSelectedType = .redPin
        pointItem.showAnimationType = .noAnimation
        kakaoMapView.add(pointItem)
    }
    #endif
    
    private func getDismissAction() -> UIAction {
        return .init { [weak self] _ in
            self?.dismiss(animated: true, completion: nil)
        }
    }
    
    private func getOpenMapAppAction() -> UIAction {
        return .init { [weak self] _ in
            guard let self = self else { return }
            
            if let kakaoMapURL: URL = URL(string: "kakaomap://"),
               UIApplication.shared.canOpenURL(kakaoMapURL) {
                
                let alertVC: UIAlertController = .init(title: nil, message: nil, preferredStyle: .actionSheet)
                let kakaoMapAction: UIAlertAction = .init(title: Localizable.OPEN_IN_KAKAOMAP_APP.string,
                                                          style: .default) { [weak self] _ in
                                                            self?.openInKakaoMapApp()
                                                          }
                let systemMapAction: UIAlertAction = .init(title: Localizable.OPEN_IN_SYSTEM_MAPS_APP.string,
                                                           style: .default) { [weak self] _ in
                                                            self?.openInSystemMapApp()
                                                           }
                alertVC.addAction(kakaoMapAction)
                alertVC.addAction(systemMapAction)
                
                if let controller: UIPopoverPresentationController = alertVC.popoverPresentationController {
                    if let openMapAppBarButtonItem: UIBarButtonItem = self.openMapAppBarButtonItem {
                        controller.barButtonItem = openMapAppBarButtonItem
                    } else {
                        controller.sourceView = self.view
                        controller.sourceRect = CGRect(origin: self.view.center, size: .zero)
                    }
                }
                
                self.present(alertVC, animated: true)
            } else {
                self.openInSystemMapApp()
            }
        }
    }
    
    private func openInSystemMapApp() {
        let placemark: MKPlacemark = .init(coordinate: CLLocationCoordinate2D(latitude: latitude, longitude: longitude))
        let mapItem: MKMapItem = .init(placemark: placemark)
        mapItem.openInMaps(launchOptions: nil)
    }
    
    private func openInKakaoMapApp() {
        guard let url: URL = URL(string: "kakaomap://look?p=\(latitude),\(longitude)") else {
            return
        }
        UIApplication.shared.open(url, options: [:], completionHandler: nil)
    }
}
