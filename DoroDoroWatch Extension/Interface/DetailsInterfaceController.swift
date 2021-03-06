//
//  DetailsInterfaceController.swift
//  DoroDoroWatch Extension
//
//  Created by Jinwoo Kim on 3/6/21.
//

import WatchKit
import MapKit
import Combine
import DoroDoroWatchAPI

final internal class DetailsInterfaceController: WKInterfaceController {
    @IBOutlet internal weak var resultGroup: WKInterfaceGroup!
    @IBOutlet internal weak var linkJusoGroup: WKInterfaceGroup!
    @IBOutlet internal weak var linkJusoHeaderLabel: WKInterfaceLabel!
    @IBOutlet internal weak var linkJusoTableView: WKInterfaceTable!
    @IBOutlet internal weak var engJusoHeaderLabel: WKInterfaceLabel!
    @IBOutlet internal weak var engJusoTableView: WKInterfaceTable!
    @IBOutlet internal weak var engJusoGroup: WKInterfaceGroup!
    @IBOutlet internal weak var mapHeaderLabel: WKInterfaceLabel!
    @IBOutlet internal weak var mapView: WKInterfaceMap!
    @IBOutlet internal weak var mapGroup: WKInterfaceGroup!
    
    @IBOutlet internal weak var loadingImageView: WKInterfaceImage!
    
    
    private var interfaceModel: DetailsInterfaceModel? = nil
    private var cancellableBag: Set<AnyCancellable> = .init()
    
    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        setAttributes()
        configureInterfaceModel()
        
        if let linkJusoData: AddrLinkJusoData = (context as? [String: AddrLinkJusoData])?["linkJusoData"] {
            loadLinkJuso(data: linkJusoData)
            interfaceModel?.loadData(linkJusoData: linkJusoData)
        } else if let roadAddr: String = (context as? [String: String])?["roadAddr"] {
            startLoadingAnimation(in: loadingImageView) { [weak self] in
                self?.resultGroup.setHidden(true)
                self?.loadingImageView.setHidden(false)
            }
            interfaceModel?.loadData(roadAddr: roadAddr)
        }
        bind()
    }
    
    private func setAttributes() {
        setTitle("Details(번역)")
        linkJusoGroup.setHidden(true)
        engJusoGroup.setHidden(true)
        mapGroup.setHidden(true)
    }
    
    private func configureInterfaceModel() {
        interfaceModel = .init()
    }
    
    private func loadLinkJuso(data: AddrLinkJusoData) {
        stopLoadingAnimation(in: loadingImageView) { [weak self] in
            self?.resultGroup.setHidden(false)
            self?.loadingImageView.setHidden(true)
        }
        
        let rows: Int = DetailsLinkJusoIndex.allCases.count
        linkJusoGroup.setHidden(false)
        linkJusoTableView.setNumberOfRows(rows, withRowType: "LinkJusoCell")
        
        for idx in 0..<rows {
            guard let object: DetailsLinkJusoObject = linkJusoTableView.rowController(at: idx) as? DetailsLinkJusoObject else {
                continue
            }
            object.configure(data: data, idx: DetailsLinkJusoIndex(rawValue: idx))
        }
    }
    
    private func loadEngJuso(data: AddrEngJusoData) {
        let rows: Int = DetailsEngJusoIndex.allCases.count
        engJusoGroup.setHidden(false)
        engJusoTableView.setNumberOfRows(rows, withRowType: "EngJusoCell")
        
        for idx in 0..<rows {
            guard let object: DetailsEngJusoObject = engJusoTableView.rowController(at: idx) as? DetailsEngJusoObject else {
                continue
            }
            object.configure(data: data, idx: DetailsEngJusoIndex(rawValue: idx))
        }
    }
    
    private func loadMap(coord: (latitude: Double, longitude: Double)) {
        mapGroup.setHidden(false)
        let coordinate: CLLocationCoordinate2D = .init(latitude: coord.latitude, longitude: coord.longitude)
        let region: MKCoordinateRegion = .init(center: coordinate, latitudinalMeters: 300, longitudinalMeters: 300)
        mapView.addAnnotation(coordinate, with: .red)
        mapView.setRegion(region)
    }
    
    private func bind() {
        interfaceModel?.linkJusoDataEvent
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] data in
                self?.loadLinkJuso(data: data)
            })
            .store(in: &cancellableBag)
        
        interfaceModel?.engJusoDataEvent
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] data in
                self?.loadEngJuso(data: data)
            })
            .store(in: &cancellableBag)
        
        interfaceModel?.coordEvent
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] coord in
                self?.loadMap(coord: coord)
            })
            .store(in: &cancellableBag)
        
        interfaceModel?.addrAPIService.linkErrorEvent
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] error in
                self?.showErrorAlert(for: error)
            })
            .store(in: &cancellableBag)
        
        interfaceModel?.addrAPIService.engErrorEvent
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] error in
                self?.showErrorAlert(for: error)
            })
            .store(in: &cancellableBag)
        
        interfaceModel?.kakaoAPIService.addressErrorEvent
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] error in
                self?.showErrorAlert(for: error)
            })
            .store(in: &cancellableBag)
        
    }
}
