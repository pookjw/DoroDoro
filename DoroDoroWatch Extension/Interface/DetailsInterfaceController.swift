//
//  DetailsInterfaceController.swift
//  DoroDoroWatch Extension
//
//  Created by Jinwoo Kim on 3/6/21.
//

import WatchKit
import MapKit
import Combine

final internal class DetailsInterfaceController: WKInterfaceController {
    @IBOutlet weak var linkJusoGroup: WKInterfaceGroup!
    @IBOutlet weak var linkJusoHeaderLabel: WKInterfaceLabel!
    @IBOutlet weak var linkJusoTableView: WKInterfaceTable!
    @IBOutlet weak var engJusoHeaderLabel: WKInterfaceLabel!
    @IBOutlet weak var engJusoTableView: WKInterfaceTable!
    @IBOutlet weak var engJusoGroup: WKInterfaceGroup!
    @IBOutlet weak var mapHeaderLabel: WKInterfaceLabel!
    @IBOutlet weak var mapView: WKInterfaceMap!
    @IBOutlet weak var mapGroup: WKInterfaceGroup!
    
    private var interfaceModel: DetailsInterfaceModel? = nil
    private var cancellableBag: Set<AnyCancellable> = .init()
    
    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        setAttributes()
        configureInterfaceModel()
        
        if let linkJusoData: AddrLinkJusoData = (context as? [String: AddrLinkJusoData])?["linkJusoData"] {
            interfaceModel?.linkJusoData = linkJusoData
            loadLinkJuso(data: linkJusoData)
        }
        bind()
        interfaceModel?.loadData()
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
        
    }
}
