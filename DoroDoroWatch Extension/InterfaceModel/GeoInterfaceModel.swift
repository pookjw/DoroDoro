//
//  GeoInterfaceModel.swift
//  DoroDoroWatch Extension
//
//  Created by Jinwoo Kim on 3/7/21.
//

import Foundation
import Combine
import DoroDoroWatchAPI

final internal class GeoInterfaceModel {
    internal var geoEvent: PassthroughSubject<String, Never> = .init()
    internal let geoAPIService: GeoAPIService = .init()
    internal let kakaoAPIService: KakaoAPIService = .init()
    
    internal init() {
        bind()
    }
    
    internal func requestGeoEvent() {
        geoAPIService.requestCurrentCoord()
    }
    
    private var cancellableBag: Set<AnyCancellable> = .init()
    
    private func bind() {
        geoAPIService.coordEvent
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] coord in
                self?.kakaoAPIService.requestCoord2AddressEvent(x: String(coord.longitude), y: String(coord.latitude))
            })
            .store(in: &cancellableBag)
        
        kakaoAPIService.coord2AddressEvent
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] data in
                guard let document: KakaoCoord2AddressDocumentData = data.documents.first else {
                    self?.kakaoAPIService.coord2AddressErrorEvent.send(.noResults)
                    return
                }
                
                let addr: String
                
                if let roadAddress: KakaoCoord2AddressRoadAddressData = document.road_address {
                    addr = roadAddress.address_name
                } else {
                    addr = document.address.address_name
                }
                self?.geoEvent.send(addr)
            })
            .store(in: &cancellableBag)
    }
}
