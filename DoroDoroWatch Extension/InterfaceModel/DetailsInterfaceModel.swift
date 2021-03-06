//
//  DetailsInterfaceModel.swift
//  DoroDoroWatch Extension
//
//  Created by Jinwoo Kim on 3/6/21.
//

import Foundation
import Combine
import DoroDoroWatchAPI

final internal class DetailsInterfaceModel {
    internal let addrAPIService: AddrAPIService = .init()
    internal let kakaoAPIService: KakaoAPIService = .init()
    internal let engJusoDataEvent: PassthroughSubject<AddrEngJusoData, Never> = .init()
    internal let coordEvent: PassthroughSubject<(latitude: Double, longitude: Double), Never> = .init()
    internal var linkJusoData: AddrLinkJusoData? = nil
    private var cancellableBag: Set<AnyCancellable> = .init()
    
    internal init() {
        bind()
    }
    
    internal func loadData() {
        guard let linkJusoData: AddrLinkJusoData = linkJusoData else {
            return
        }
        
        addrAPIService.requestEngEvent(keyword: linkJusoData.roadAddr, countPerPage: 1)
        kakaoAPIService.requestAddressEvent(query: linkJusoData.roadAddr,
                                            analyze_type: .exact,
                                            page: 1, size: 1)
    }
    
    private func bind() {
        addrAPIService.engEvent
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] data in
                guard let engJusoData: AddrEngJusoData = data.juso.first else {
                    return
                }
                self?.engJusoDataEvent.send(engJusoData)
            })
            .store(in: &cancellableBag)
        
        kakaoAPIService.addressEvent
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] data in
                guard let addressDocumentData: KakaoAddressDocumentData = data.documents.first else {
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
