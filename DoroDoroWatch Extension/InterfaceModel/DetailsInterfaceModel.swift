//
//  DetailsInterfaceModel.swift
//  DoroDoroWatch Extension
//
//  Created by Jinwoo Kim on 3/6/21.
//

import Foundation
import Combine
import DoroDoroWatchAPI

internal final class DetailsInterfaceModel {
    internal let addrAPIService: AddrAPIService = .init()
    internal let kakaoAPIService: KakaoAPIService = .init()
    internal var linkJusoDataEvent: PassthroughSubject<AddrLinkJusoData, Never> = .init()
    internal let engJusoDataEvent: PassthroughSubject<AddrEngJusoData, Never> = .init()
    internal let coordEvent: PassthroughSubject<(latitude: Double, longitude: Double), Never> = .init()
    private var cancellableBag: Set<AnyCancellable> = .init()
    
    internal init() {
        bind()
    }
    
    internal func loadData(linkJusoData: AddrLinkJusoData) {
        linkJusoDataEvent.send(linkJusoData)
        addrAPIService.requestEngEvent(keyword: linkJusoData.roadAddr, countPerPage: 1)
        kakaoAPIService.requestAddressEvent(query: linkJusoData.roadAddr,
                                            analyze_type: .exact,
                                            page: 1, size: 1)
    }
    
    internal func loadData(roadAddr: String) {
        addrAPIService.requestLinkEvent(keyword: roadAddr)
    }
    
    private func bind() {
        addrAPIService.linkEvent
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] data in
                guard let linkJusoData: AddrLinkJusoData = data.juso.first else {
                    self?.addrAPIService.linkErrorEvent.send(.noResults)
                    return
                }
                self?.linkJusoDataEvent.send(linkJusoData)
                self?.loadData(linkJusoData: linkJusoData)
            })
            .store(in: &cancellableBag)
        
        addrAPIService.engEvent
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] data in
                guard let engJusoData: AddrEngJusoData = data.juso.first else {
                    self?.addrAPIService.engErrorEvent.send(.noResults)
                    return
                }
                self?.engJusoDataEvent.send(engJusoData)
            })
            .store(in: &cancellableBag)
        
        kakaoAPIService.addressEvent
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] data in
                guard let addressDocumentData: KakaoAddressDocumentData = data.documents.first else {
                    self?.kakaoAPIService.addressErrorEvent.send(.noResults)
                    return
                }
                
                guard let latitude: Double = Double(addressDocumentData.y),
                      let longitude: Double = Double(addressDocumentData.x) else {
                    return
                }
                self?.coordEvent.send((latitude: latitude, longitude: longitude))
            })
            .store(in: &cancellableBag)
    }
}
