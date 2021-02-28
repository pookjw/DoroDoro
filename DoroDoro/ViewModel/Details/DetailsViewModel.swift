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
    private var engJusoData: AddrEngJusoData? = nil
    private var coordJusoData: AddrCoordJusoData? = nil
    private var cancellableBag: Set<AnyCancellable> = .init()
    
    internal init() {
        bind()
    }
    
    internal func loadData() {
        updateJusoItems()
        if let linkJusoData: AddrLinkJusoData = linkJusoData {
            APIService.shared.requestAddrEngEvent(keyword: linkJusoData.roadAddr)
            APIService.shared.requestCoordEvent(data: linkJusoData.convertToAddrCoordSearchData())
        }
    }
    
    private func updateJusoItems() {
        guard var snapshot: Snapshot = dataSource?.snapshot(),
            let linkJusoData: AddrLinkJusoData = linkJusoData else {
            return
        }
        
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
        
//        let items: [DetailInfoItem] = [
//            .init(title: "전체 도로명주소", subTitle: linkJusoData.roadAddr),
//            .init(title: "도로명주소", subTitle: linkJusoData.roadAddrPart1),
//            .init(title: "도로명주소 참고항목", subTitle: linkJusoData.roadAddrPart2 ?? "(데이터 없음)"),
//            .init(title: "지번주소", subTitle: linkJusoData.jibunAddr),
//            .init(title: "우편번호", subTitle: linkJusoData.zipNo),
//            .init(title: "행정구역코드", subTitle: linkJusoData.admCd),
//            .init(title: "도로명코드", subTitle: linkJusoData.rnMgtSn),
//            .init(title: "건물관리번호", subTitle: linkJusoData.bdMgtSn),
//            .init(title: "상세건물명", subTitle: linkJusoData.detBdNmList ?? ""),
//            .init(title: "건물명", subTitle: linkJusoData.bdNm ?? ""),
//            .init(title: "공동주택여부", subTitle: linkJusoData.bdKdcd ?? ""),
//            .init(title: "시도명", subTitle: linkJusoData.siNm),
//            .init(title: "시군구명", subTitle: linkJusoData.sggNm),
//            .init(title: "읍면동명", subTitle: linkJusoData.emdNm),
//            .init(title: "법정리명", subTitle: linkJusoData.liNm ?? ""),
//            .init(title: "도로명", subTitle: linkJusoData.rn),
//            .init(title: "지하여부", subTitle: linkJusoData.udrtYn),
//            .init(title: "건물본번", subTitle: linkJusoData.buldMnnm),
//            .init(title: "건물부번", subTitle: linkJusoData.buldSlno),
//            .init(title: "산여부", subTitle: linkJusoData.mtYn),
//            .init(title: "지번본번(번지)", subTitle: linkJusoData.lnbrMnnm),
//            .init(title: "지번부번(호)", subTitle: linkJusoData.lnbrSlno),
//            .init(title: "읍면동일련번호", subTitle: linkJusoData.emdNo),
//            .init(title: "변동이력여부", subTitle: linkJusoData.hstryYn ?? ""),
//            .init(title: "관련지번", subTitle: linkJusoData.relJibun ?? ""),
//            .init(title: "관할주민센터 (참고정보)", subTitle: linkJusoData.hemdNm ?? "")
//        ]
        
        let items: [DetailInfoItem] = [
            .init(itemType: .link("", ""))
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
//            .init(title: "영문 도로명주소", subTitle: engJusoData.roadAddr)
            .init(itemType: .eng("영문 도로명주소", engJusoData.roadAddr))
        ]
        
        snapshot.appendItems(items, toSection: engHeaderItem)
        dataSource?.apply(snapshot, animatingDifferences: false)
    }
    
    private func updateCoordItems() {
        guard var snapshot: Snapshot = dataSource?.snapshot(),
            let coordJusoData: AddrCoordJusoData = coordJusoData,
            let latitude: Double = Double(coordJusoData.entX),
            let longitude: Double = Double(coordJusoData.entY)
        else {
            return
        }
        
        // 세부정보 데이터 생성
        let coordHeaderItem: DetailHeaderItem = {
            // 이미 기존에 생성된 Header가 있는 경우 그대로 쓴다.
            if let coordHeaderItem: DetailHeaderItem = snapshot.sectionIdentifiers.first(where: { $0.itemType == .coord }) {
                return coordHeaderItem
            } else {
                let coordHeaderItem: DetailHeaderItem = .init(itemType: .coord)
                
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
            .init(itemType: .coord(latitude, longitude))
        ]
        
        snapshot.appendItems(items, toSection: coordHeaderItem)
        dataSource?.apply(snapshot, animatingDifferences: false)
    }
    
    private func bind() {
        APIService.shared.addrEngEvent
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] data in
                self?.engJusoData = data.juso[0]
                self?.updateEngItems()
            })
            .store(in: &cancellableBag)
        
        APIService.shared.addrCoordEvent
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] data in
                self?.coordJusoData = data.juso[0]
                self?.updateCoordItems()
            })
            .store(in: &cancellableBag)
    }
}
