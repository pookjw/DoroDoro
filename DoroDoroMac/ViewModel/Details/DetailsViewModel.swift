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
            .init(text: "전체 도로명주소", secondaryText: wrappedNoData(linkJusoData.roadAddr)),
            .init(text: "도로명주소", secondaryText: wrappedNoData(linkJusoData.roadAddrPart1)),
            .init(text: "도로명주소 참고항목", secondaryText: wrappedNoData(linkJusoData.roadAddrPart2)),
            .init(text: "지번주소", secondaryText: wrappedNoData(linkJusoData.jibunAddr)),
            .init(text: "우편번호", secondaryText: wrappedNoData(linkJusoData.zipNo)),
            .init(text: "행정구역코드", secondaryText: wrappedNoData(linkJusoData.admCd)),
            .init(text: "도로명코드", secondaryText: wrappedNoData(linkJusoData.rnMgtSn)),
            .init(text: "건물관리번호", secondaryText: wrappedNoData(linkJusoData.bdMgtSn)),
            .init(text: "상세건물명", secondaryText: wrappedNoData(linkJusoData.detBdNmList)),
            .init(text: "건물명", secondaryText: wrappedNoData(linkJusoData.bdNm)),
            .init(text: "공동주택여부", secondaryText: wrappedBdKdcd(linkJusoData.bdKdcd)),
            .init(text: "시도명", secondaryText: wrappedNoData(linkJusoData.siNm)),
            .init(text: "시군구명", secondaryText: wrappedNoData(linkJusoData.sggNm)),
            .init(text: "읍면동명", secondaryText: wrappedNoData(linkJusoData.emdNm)),
            .init(text: "법정리명", secondaryText: wrappedNoData(linkJusoData.liNm)),
            .init(text: "도로명", secondaryText: wrappedNoData(linkJusoData.rn)),
            .init(text: "지하여부", secondaryText: wrappedUdrtYn(linkJusoData.udrtYn)),
            .init(text: "건물본번", secondaryText: wrappedNoData(linkJusoData.buldMnnm)),
            .init(text: "건물부번", secondaryText: wrappedNoData(linkJusoData.buldSlno)),
            .init(text: "산여부", secondaryText: wrappedMtYn(linkJusoData.mtYn)),
            .init(text: "지번본번(번지)", secondaryText: wrappedNoData(linkJusoData.lnbrMnnm)),
            .init(text: "지번부번(호)", secondaryText: wrappedNoData(linkJusoData.lnbrSlno)),
            .init(text: "읍면동일련번호", secondaryText: wrappedNoData(linkJusoData.emdNo)),
            .init(text: "관련지번", secondaryText: wrappedNoData(linkJusoData.relJibun)),
            .init(text: "관할주민센터(참고정보)", secondaryText: wrappedNoData(linkJusoData.hemdNm))
        ]
    }
    
    private func convertEngData(_ engJusoData: AddrEngJusoData) -> [DetailsListResultItem] {
        return [
            .init(text: "영문 도로명주소", secondaryText: wrappedNoData(engJusoData.roadAddr)),
            .init(text: "영문 지번주소", secondaryText: wrappedNoData(engJusoData.jibunAddr)),
            .init(text: "영문 시도명", secondaryText: wrappedNoData(engJusoData.siNm)),
            .init(text: "영문 시군구명", secondaryText: wrappedNoData(engJusoData.sggNm)),
            .init(text: "영문 읍면동명", secondaryText: wrappedNoData(engJusoData.emdNm)),
            .init(text: "영문 법정리명", secondaryText: wrappedNoData(engJusoData.liNm)),
            .init(text: "영문 도로명", secondaryText: wrappedNoData(engJusoData.rn))
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
    
    //
    
    private func wrappedNoData(_ text: String?) -> String {
        guard let text: String = text else {
            return Localizable.NO_DATA.string
        }
        return text.isEmpty ? Localizable.NO_DATA.string : text
    }
    
    private func wrappedBdKdcd(_ bdKdcd: String?) -> String {
        guard let bdKdcd: String = bdKdcd else {
            return Localizable.NO_DATA.string
        }
        return (bdKdcd == "0") ? "비공동주택" : "공동주택"
    }
    
    private func wrappedUdrtYn(_ udrtYn: String?) -> String {
        guard let udrtYn: String = udrtYn else {
            return Localizable.NO_DATA.string
        }
        return (udrtYn == "0") ? "지상" : "지하"
    }
    
    private func wrappedMtYn(_ mtYn: String?) -> String {
        guard let mtYn: String = mtYn else {
            return Localizable.NO_DATA.string
        }
        return (mtYn == "0") ? "대지" : "산"
    }
}
