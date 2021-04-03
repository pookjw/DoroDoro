//
//  DetailsViewModel.swift
//  DoroDoroMac
//
//  Created by Jinwoo Kim on 3/19/21.
//

import Foundation
import Combine
import DoroDoroMacAPI

internal final class DetailsViewModel {
    internal var refreshedEvent: PassthroughSubject<Void, Never> = .init()
    internal let addrAPIService: AddrAPIService = .init()
    internal let kakaoAPIService: KakaoAPIService = .init()
    
    internal var linkResultItemEvent: PassthroughSubject<[DetailsListResultItem], Never> = .init()
    internal let engResultItemEvent: PassthroughSubject<[DetailsListResultItem], Never> = .init()
    internal let mapResultItemEvent: PassthroughSubject<DetailsMapResultItem, Never> = .init()
    
    private var cancellableBag: Set<AnyCancellable> = .init()
    
    internal init() {
        bind()
    }
    
    internal func loadData(_ linkJusoData: AddrLinkJusoData) {
        let items: [DetailsListResultItem] = convertLinkData(linkJusoData)
        linkResultItemEvent.send(items)
        
        addrAPIService.requestEngEvent(keyword: linkJusoData.roadAddr, currentPage: 1)
        kakaoAPIService.requestAddressEvent(query: linkJusoData.roadAddr, analyze_type: .exact, page: 1, size: 1)
    }
    
    internal func loadData(_ roadAddr: String) {
        addrAPIService.requestLinkEvent(keyword: roadAddr)
    }
    
    private func convertLinkData(_ linkJusoData: AddrLinkJusoData) -> [DetailsListResultItem] {
        return [
            .init(text: "전체 도로명주소", secondaryText: linkJusoData.roadAddr.wrappedNoData()),
            .init(text: "도로명주소", secondaryText: linkJusoData.roadAddrPart1.wrappedNoData()),
            .init(text: "도로명주소 참고항목", secondaryText: linkJusoData.roadAddrPart2.wrappedNoData()),
            .init(text: "지번주소", secondaryText: linkJusoData.jibunAddr.wrappedNoData()),
            .init(text: "우편번호", secondaryText: linkJusoData.zipNo.wrappedNoData()),
            .init(text: "행정구역코드", secondaryText: linkJusoData.admCd.wrappedNoData()),
            .init(text: "도로명코드", secondaryText: linkJusoData.rnMgtSn.wrappedNoData()),
            .init(text: "건물관리번호", secondaryText: linkJusoData.bdMgtSn.wrappedNoData()),
            .init(text: "상세건물명", secondaryText: linkJusoData.detBdNmList.wrappedNoData()),
            .init(text: "건물명", secondaryText: linkJusoData.bdNm.wrappedNoData()),
            .init(text: "공동주택여부", secondaryText: linkJusoData.bdKdcd.wrappedBdKdcd()),
            .init(text: "시도명", secondaryText: linkJusoData.siNm.wrappedNoData()),
            .init(text: "시군구명", secondaryText: linkJusoData.sggNm.wrappedNoData()),
            .init(text: "읍면동명", secondaryText: linkJusoData.emdNm.wrappedNoData()),
            .init(text: "법정리명", secondaryText: linkJusoData.liNm.wrappedNoData()),
            .init(text: "도로명", secondaryText: linkJusoData.rn.wrappedNoData()),
            .init(text: "지하여부", secondaryText: linkJusoData.udrtYn.wrappedUdrtYn()),
            .init(text: "건물본번", secondaryText: linkJusoData.buldMnnm.wrappedNoData()),
            .init(text: "건물부번", secondaryText: linkJusoData.buldSlno.wrappedNoData()),
            .init(text: "산여부", secondaryText: linkJusoData.mtYn.wrappedMtYn()),
            .init(text: "지번본번(번지)", secondaryText: linkJusoData.lnbrMnnm.wrappedNoData()),
            .init(text: "지번부번(호)", secondaryText: linkJusoData.lnbrSlno.wrappedNoData()),
            .init(text: "읍면동일련번호", secondaryText: linkJusoData.emdNo.wrappedNoData()),
            .init(text: "관련지번", secondaryText: linkJusoData.relJibun.wrappedNoData()),
            .init(text: "관할주민센터(참고정보)", secondaryText: linkJusoData.hemdNm.wrappedNoData())
        ]
    }
    
    private func convertEngData(_ engJusoData: AddrEngJusoData) -> [DetailsListResultItem] {
        return [
            .init(text: "영문 도로명주소", secondaryText: engJusoData.roadAddr.wrappedNoData()),
            .init(text: "영문 지번주소", secondaryText: engJusoData.jibunAddr.wrappedNoData()),
            .init(text: "영문 시도명", secondaryText: engJusoData.siNm.wrappedNoData()),
            .init(text: "영문 시군구명", secondaryText: engJusoData.sggNm.wrappedNoData()),
            .init(text: "영문 읍면동명", secondaryText: engJusoData.emdNm.wrappedNoData()),
            .init(text: "영문 법정리명", secondaryText: engJusoData.liNm.wrappedNoData()),
            .init(text: "영문 도로명", secondaryText: engJusoData.rn.wrappedNoData())
        ]
    }
    
    private func convertMapData(_ addressDocumentData: KakaoAddressDocumentData) -> DetailsMapResultItem? {
        guard let latitude: Double = Double(addressDocumentData.y),
              let longitude: Double = Double(addressDocumentData.x) else {
            return nil
        }
        
        return .init(latitude: latitude, longitude: longitude, locationTitle: addressDocumentData.address_name)
    }
    
    private func bind() {
        addrAPIService.linkEvent
            .sink(receiveValue: { [weak self] data in
                guard let self = self else {
                    return
                }
                
                guard let linkJusoData: AddrLinkJusoData = data.juso.first else {
                    self.addrAPIService.linkErrorEvent.send(.noResults)
                    return
                }
                let items: [DetailsListResultItem] = self.convertLinkData(linkJusoData)
                
                self.linkResultItemEvent.send(items)
                self.loadData(linkJusoData)
                self.refreshedEvent.send()
            })
            .store(in: &cancellableBag)
        
        addrAPIService.engEvent
            .sink(receiveValue: { [weak self] data in
                guard let self = self else {
                    return
                }
                
                guard let engJusoData: AddrEngJusoData = data.juso.first else {
                    self.addrAPIService.engErrorEvent.send(.noResults)
                    return
                }
                
                let items: [DetailsListResultItem] = self.convertEngData(engJusoData)
                self.engResultItemEvent.send(items)
                
                self.refreshedEvent.send()
            })
            .store(in: &cancellableBag)
        
        kakaoAPIService.addressEvent
            .sink(receiveValue: { [weak self] data in
                guard let addressDocumentData: KakaoAddressDocumentData = data.documents.first else {
                    self?.kakaoAPIService.addressErrorEvent.send(.noResults)
                    return
                }
                
                if let item: DetailsMapResultItem = self?.convertMapData(addressDocumentData) {
                    self?.mapResultItemEvent.send(item)
                }
                
                self?.refreshedEvent.send()
            })
            .store(in: &cancellableBag)
    }
}
