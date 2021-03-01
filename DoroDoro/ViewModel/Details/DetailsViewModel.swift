//
//  DetailsViewModel.swift
//  DoroDoro
//
//  Created by Jinwoo Kim on 3/1/21.
//

import Foundation
import UIKit
import Combine

final internal class DetailsViewModel {
    internal typealias DataSource = UICollectionViewDiffableDataSource<DetailHeaderItem, DetailInfoItem>
    internal typealias Snapshot = NSDiffableDataSourceSnapshot<DetailHeaderItem, DetailInfoItem>
    
    internal var dataSource: DataSource? = nil
    internal var linkJusoData: AddrLinkJusoData? = nil
    internal let addrAPIService: AddrAPIService = .init()
    internal let kakaoAPIService: KakaoAPIService = .init()
    private var engJusoData: AddrEngJusoData? = nil
    private var addressDocumentData: KakaoAddressDocumentData? = nil
    private var cancellableBag: Set<AnyCancellable> = .init()
    
    internal init() {
        bind()
    }
    
    internal func getSectionItemType(from indexPath: IndexPath) -> DetailHeaderItem.ItemType? {
        guard let sectionIdentifiers: [DetailHeaderItem] = dataSource?.snapshot().sectionIdentifiers else {
            return nil
        }
        guard sectionIdentifiers.count > indexPath.section else {
            return nil
        }
        return sectionIdentifiers[indexPath.section].itemType
    }
    
    internal func loadData() {
        updateLinkItems()
        if let linkJusoData: AddrLinkJusoData = linkJusoData {
            addrAPIService.requestEngEvent(keyword: linkJusoData.roadAddr)
            kakaoAPIService.requestAddressEvent(query: linkJusoData.roadAddr,
                                                analyzeType: .exact, page: 1, size: 1)
        }
    }
    
    private func updateLinkItems() {
        guard var snapshot: Snapshot = dataSource?.snapshot(),
            let linkJusoData: AddrLinkJusoData = linkJusoData else {
            return
        }
        
        snapshot.deleteAllItems()
        
        // 도로명주소 데이터 생성
        let linkHeaderItem: DetailHeaderItem = {
            // 이미 기존에 생성된 Header가 있는 경우 그대로 쓴다.
            if let linkHeaderItem: DetailHeaderItem = snapshot.sectionIdentifiers.first(where: { $0.itemType == .link }) {
                return linkHeaderItem
            } else {
                let headerItem: DetailHeaderItem = .init(itemType: .link)
                snapshot.appendSections([headerItem])
                return headerItem
            }
        }()
        
        let items: [DetailInfoItem] = [
            .init(itemType: .link("전체 도로명주소", wrappedNoData(linkJusoData.roadAddr))),
            .init(itemType: .link("도로명주소", wrappedNoData(linkJusoData.roadAddrPart1))),
            .init(itemType: .link("도로명주소 참고항목", wrappedNoData(linkJusoData.roadAddrPart2))),
            .init(itemType: .link("지번주소", wrappedNoData(linkJusoData.jibunAddr))),
            .init(itemType: .link("우편번호", wrappedNoData(linkJusoData.zipNo))),
            .init(itemType: .link("행정구역코드", wrappedNoData(linkJusoData.admCd))),
            .init(itemType: .link("도로명코드", wrappedNoData(linkJusoData.rnMgtSn))),
            .init(itemType: .link("건물관리번호", wrappedNoData(linkJusoData.bdMgtSn))),
            .init(itemType: .link("상세건물명", wrappedNoData(linkJusoData.detBdNmList))),
            .init(itemType: .link("건물명", wrappedNoData(linkJusoData.bdNm))),
            .init(itemType: .link("공동주택여부", wrappedBdKdcd(linkJusoData.bdKdcd))),
            .init(itemType: .link("시도명", wrappedNoData(linkJusoData.siNm))),
            .init(itemType: .link("시군구명", wrappedNoData(linkJusoData.sggNm))),
            .init(itemType: .link("읍면동명", wrappedNoData(linkJusoData.emdNm))),
            .init(itemType: .link("법정리명", wrappedNoData(linkJusoData.liNm))),
            .init(itemType: .link("도로명", wrappedNoData(linkJusoData.rn))),
            .init(itemType: .link("지하여부", wrappedUdrtYn(linkJusoData.udrtYn))),
            .init(itemType: .link("건물본번", wrappedNoData(linkJusoData.buldMnnm))),
            .init(itemType: .link("건물부번", wrappedNoData(linkJusoData.buldSlno))),
            .init(itemType: .link("산여부", wrappedMtYn(linkJusoData.mtYn))),
            .init(itemType: .link("지번본번(번지)", wrappedNoData(linkJusoData.lnbrMnnm))),
            .init(itemType: .link("지번부번(호)", wrappedNoData(linkJusoData.lnbrSlno))),
            .init(itemType: .link("읍면동일련번호", wrappedNoData(linkJusoData.emdNo))),
            .init(itemType: .link("관련지번", wrappedNoData(linkJusoData.relJibun))),
            .init(itemType: .link("관할주민센터(참고정보)", wrappedNoData(linkJusoData.hemdNm)))
        ]
        
        snapshot.appendItems(items, toSection: linkHeaderItem)
        dataSource?.apply(snapshot, animatingDifferences: true)
    }
    
    private func updateEngItems() {
        guard var snapshot: Snapshot = dataSource?.snapshot(),
            let engJusoData: AddrEngJusoData = engJusoData else {
            return
        }
        
        // 세부정보 데이터 생성
        let engHeaderItem: DetailHeaderItem = {
            // 이미 기존에 생성된 Header가 있는 경우 그대로 쓴다.
            if let engHeaderItem: DetailHeaderItem = snapshot.sectionIdentifiers.first(where: { $0.itemType == .eng }) {
                return engHeaderItem
            } else {
                let engHeaderItem: DetailHeaderItem = .init(itemType: .eng)
                
                // 도로명주소 Section 밑에 생성한다.
                if let linkHeaderItem: DetailHeaderItem = snapshot.sectionIdentifiers.first(where: { $0.itemType == .link }) {
                    snapshot.insertSections([engHeaderItem], afterSection: linkHeaderItem)
                } else {
                    snapshot.appendSections([engHeaderItem])
                }
                
                return engHeaderItem
            }
        }()
        
        let items: [DetailInfoItem] = [
            .init(itemType: .eng("영문 도로명주소", wrappedNoData(engJusoData.roadAddr))),
            .init(itemType: .eng("영문 지번주소", wrappedNoData(engJusoData.jibunAddr))),
            .init(itemType: .eng("영문 시도명", wrappedNoData(engJusoData.siNm))),
            .init(itemType: .eng("영문 시군구명", wrappedNoData(engJusoData.sggNm))),
            .init(itemType: .eng("영문 읍면동명", wrappedNoData(engJusoData.emdNm))),
            .init(itemType: .eng("영문 법정리명", wrappedNoData(engJusoData.liNm))),
            .init(itemType: .eng("영문 도로명", wrappedNoData(engJusoData.rn)))
        ]
        
        snapshot.appendItems(items, toSection: engHeaderItem)
        dataSource?.apply(snapshot, animatingDifferences: false)
    }
    
    private func updateMapItems() {
        guard var snapshot: Snapshot = dataSource?.snapshot(),
            let addressDocumentData: KakaoAddressDocumentData = addressDocumentData,
            let latitude: Double = Double(addressDocumentData.y),
            let longitude: Double = Double(addressDocumentData.x)
        else {
            return
        }
        
        // 세부정보 데이터 생성
        let coordHeaderItem: DetailHeaderItem = {
            // 이미 기존에 생성된 Header가 있는 경우 그대로 쓴다.
            if let coordHeaderItem: DetailHeaderItem = snapshot.sectionIdentifiers.first(where: { $0.itemType == .map }) {
                return coordHeaderItem
            } else {
                let coordHeaderItem: DetailHeaderItem = .init(itemType: .map)
                
                if let engHeaderItem: DetailHeaderItem = snapshot.sectionIdentifiers.first(where: { $0.itemType == .eng }) {
                    // 영문주소 Section이 존재할 경우 그 밑에 생성한다.
                    snapshot.insertSections([coordHeaderItem], afterSection: engHeaderItem)
                } else if let linkHeaderItem: DetailHeaderItem = snapshot.sectionIdentifiers.first(where: { $0.itemType == .link }) {
                    // 영문주소 Section이 없고 도로명주소 Section이 있을 경우 그 밑에 생성한다.
                    snapshot.insertSections([coordHeaderItem], afterSection: linkHeaderItem)
                } else {
                    snapshot.appendSections([coordHeaderItem])
                }
                
                return coordHeaderItem
            }
        }()
        
        let items: [DetailInfoItem] = [
            .init(itemType: .map(latitude, longitude))
        ]
        
        snapshot.appendItems(items, toSection: coordHeaderItem)
        dataSource?.apply(snapshot, animatingDifferences: false)
    }
    
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
    
    private func bind() {
        addrAPIService.engEvent
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] data in
                self?.engJusoData = data.juso.first
                self?.updateEngItems()
            })
            .store(in: &cancellableBag)
        
        kakaoAPIService.addressEvent
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] data in
                self?.addressDocumentData = data.documents.first
                self?.updateMapItems()
            })
            .store(in: &cancellableBag)
    }
}
