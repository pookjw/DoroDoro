//
//  DetailsViewModel.swift
//  DoroDoro
//
//  Created by Jinwoo Kim on 3/1/21.
//

import UIKit
import Combine
import DoroDoroAPI

internal final class DetailsViewModel {
    internal typealias DataSource = UICollectionViewDiffableDataSource<DetailHeaderItem, DetailResultItem>
    private typealias Snapshot = NSDiffableDataSourceSnapshot<DetailHeaderItem, DetailResultItem>
    
    private var dataSource: DataSource
    internal var refreshedEvent: PassthroughSubject<Void, Never> = .init()
    internal var bookmarkEvent: PassthroughSubject<Bool, Never> = .init()
    internal let addrAPIService: AddrAPIService = .init()
    internal let kakaoAPIService: KakaoAPIService = .init()
    private var roadAddr: String? = nil
    private var cancellableBag: Set<AnyCancellable> = .init()
    
    internal init(dataSource: DataSource) {
        self.dataSource = dataSource
        bind()
    }
    
    internal func toggleBookmark() {
        guard let roadAddr: String = roadAddr else { return }
        BookmarksService.shared.toggleBookmark(roadAddr)
    }
    
    internal func getHeaderItem(from indexPath: IndexPath) -> DetailHeaderItem? {
        guard dataSource.snapshot().numberOfSections > indexPath.section else {
            return nil
        }
        return dataSource.snapshot().sectionIdentifiers[indexPath.section]
    }
    
    internal func getResultItem(from indexPath: IndexPath) -> DetailResultItem? {
        let sectionIdentifiers: [DetailHeaderItem] = dataSource.snapshot().sectionIdentifiers
        
        guard sectionIdentifiers.count > indexPath.section else {
            return nil
        }
        
        let resultItems: [DetailResultItem] = dataSource.snapshot().itemIdentifiers(inSection: sectionIdentifiers[indexPath.section])
        
        guard resultItems.count > indexPath.row else {
            return nil
        }
        
        return resultItems[indexPath.row]
    }
    
    internal func loadData(_ linkJusoData: AddrLinkJusoData) {
        deleteAllItems()
        roadAddr = linkJusoData.roadAddr
        checkBookmarkedStatus()
        updateLinkItems(linkJusoData)
        addrAPIService.requestEngEvent(keyword: linkJusoData.roadAddr, countPerPage: 1)
        kakaoAPIService.requestAddressEvent(query: linkJusoData.roadAddr,
                                            analyze_type: .exact, page: 1, size: 1)
    }
    
    internal func loadData(_ roadAddr: String) {
        deleteAllItems()
        self.roadAddr = roadAddr
        addrAPIService.requestLinkEvent(keyword: roadAddr)
    }
    
    private func deleteAllItems() {
        var snapshot: Snapshot = dataSource.snapshot()
        snapshot.deleteAllItems()
        dataSource.apply(snapshot, animatingDifferences: true)
    }
    
    private func updateLinkItems(_ linkJusoData: AddrLinkJusoData) {
        var snapshot: Snapshot = dataSource.snapshot()
        
        // 도로명주소 데이터 생성
        let linkHeaderItem: DetailHeaderItem = {
            // 이미 기존에 생성된 Header가 있는 경우 그대로 쓴다.
            if let linkHeaderItem: DetailHeaderItem = snapshot.sectionIdentifiers.first(where: { $0.headerType == .link }) {
                snapshot.deleteSections([linkHeaderItem])
                snapshot.appendSections([linkHeaderItem])
                return linkHeaderItem
            } else {
                let linkHeaderItem: DetailHeaderItem = .init(headerType: .link)
                snapshot.appendSections([linkHeaderItem])
                return linkHeaderItem
            }
        }()
        
        let items: [DetailResultItem] = [
            .init(resultType: .link(text: "전체 도로명주소", secondaryText: linkJusoData.roadAddr.wrappedNoData())),
            .init(resultType: .link(text: "도로명주소", secondaryText: linkJusoData.roadAddrPart1.wrappedNoData())),
            .init(resultType: .link(text: "도로명주소 참고항목", secondaryText: linkJusoData.roadAddrPart2.wrappedNoData())),
            .init(resultType: .link(text: "지번주소", secondaryText: linkJusoData.jibunAddr.wrappedNoData())),
            .init(resultType: .link(text: "우편번호", secondaryText: linkJusoData.zipNo.wrappedNoData())),
            .init(resultType: .link(text: "행정구역코드", secondaryText: linkJusoData.admCd.wrappedNoData())),
            .init(resultType: .link(text: "도로명코드", secondaryText: linkJusoData.rnMgtSn.wrappedNoData())),
            .init(resultType: .link(text: "건물관리번호", secondaryText: linkJusoData.bdMgtSn.wrappedNoData())),
            .init(resultType: .link(text: "상세건물명", secondaryText: linkJusoData.detBdNmList.wrappedNoData())),
            .init(resultType: .link(text: "건물명", secondaryText: linkJusoData.bdNm.wrappedNoData())),
            .init(resultType: .link(text: "공동주택여부", secondaryText: linkJusoData.bdKdcd.wrappedBdKdcd())),
            .init(resultType: .link(text: "시도명", secondaryText: linkJusoData.siNm.wrappedNoData())),
            .init(resultType: .link(text: "시군구명", secondaryText: linkJusoData.sggNm.wrappedNoData())),
            .init(resultType: .link(text: "읍면동명", secondaryText: linkJusoData.emdNm.wrappedNoData())),
            .init(resultType: .link(text: "법정리명", secondaryText: linkJusoData.liNm.wrappedNoData())),
            .init(resultType: .link(text: "도로명", secondaryText: linkJusoData.rn.wrappedNoData())),
            .init(resultType: .link(text: "지하여부", secondaryText: linkJusoData.udrtYn.wrappedUdrtYn())),
            .init(resultType: .link(text: "건물본번", secondaryText: linkJusoData.buldMnnm.wrappedNoData())),
            .init(resultType: .link(text: "건물부번", secondaryText: linkJusoData.buldSlno.wrappedNoData())),
            .init(resultType: .link(text: "산여부", secondaryText: linkJusoData.mtYn.wrappedMtYn())),
            .init(resultType: .link(text: "지번본번(번지)", secondaryText: linkJusoData.lnbrMnnm.wrappedNoData())),
            .init(resultType: .link(text: "지번부번(호)", secondaryText: linkJusoData.lnbrSlno.wrappedNoData())),
            .init(resultType: .link(text: "읍면동일련번호", secondaryText: linkJusoData.emdNo.wrappedNoData())),
            .init(resultType: .link(text: "관련지번", secondaryText: linkJusoData.relJibun.wrappedNoData())),
            .init(resultType: .link(text: "관할주민센터(참고정보)", secondaryText: linkJusoData.hemdNm.wrappedNoData()))
        ]
        
        snapshot.appendItems(items, toSection: linkHeaderItem)
        sortSnapshot(&snapshot)
        dataSource.apply(snapshot, animatingDifferences: true)
        refreshedEvent.send()
    }
    
    private func updateEngItems(_ engJusoData: AddrEngJusoData) {
        var snapshot: Snapshot = dataSource.snapshot()
        
        // 세부정보 데이터 생성
        let engHeaderItem: DetailHeaderItem = {
            // 이미 기존에 생성된 Header가 있는 경우 그대로 쓴다.
            if let engHeaderItem: DetailHeaderItem = snapshot.sectionIdentifiers.first(where: { $0.headerType == .eng }) {
                snapshot.deleteSections([engHeaderItem])
                snapshot.appendSections([engHeaderItem])
                return engHeaderItem
            } else {
                let engHeaderItem: DetailHeaderItem = .init(headerType: .eng)
                snapshot.appendSections([engHeaderItem])
                return engHeaderItem
            }
        }()
        
        let items: [DetailResultItem] = [
            .init(resultType: .eng(text: "영문 도로명주소", secondaryText: engJusoData.roadAddr.wrappedNoData())),
            .init(resultType: .eng(text: "영문 지번주소", secondaryText: engJusoData.jibunAddr.wrappedNoData())),
            .init(resultType: .eng(text: "영문 시도명", secondaryText: engJusoData.siNm.wrappedNoData())),
            .init(resultType: .eng(text: "영문 시군구명", secondaryText: engJusoData.sggNm.wrappedNoData())),
            .init(resultType: .eng(text: "영문 읍면동명", secondaryText: engJusoData.emdNm.wrappedNoData())),
            .init(resultType: .eng(text: "영문 법정리명", secondaryText: engJusoData.liNm.wrappedNoData())),
            .init(resultType: .eng(text: "영문 도로명", secondaryText: engJusoData.rn.wrappedNoData()))
        ]
        
        snapshot.appendItems(items, toSection: engHeaderItem)
        sortSnapshot(&snapshot)
        dataSource.apply(snapshot, animatingDifferences: false)
        refreshedEvent.send()
    }
    
    private func updateMapItems(_ addressDocumentData: KakaoAddressDocumentData) {
        guard let latitude: Double = Double(addressDocumentData.y),
            let longitude: Double = Double(addressDocumentData.x)
        else {
            return
        }
        
        var snapshot: Snapshot = dataSource.snapshot()
        
        // 세부정보 데이터 생성
        let coordHeaderItem: DetailHeaderItem = {
            // 이미 기존에 생성된 Header가 있는 경우 그대로 쓴다.
            if let coordHeaderItem: DetailHeaderItem = snapshot.sectionIdentifiers.first(where: { $0.headerType == .map }) {
                snapshot.deleteSections([coordHeaderItem])
                snapshot.appendSections([coordHeaderItem])
                return coordHeaderItem
            } else {
                let coordHeaderItem: DetailHeaderItem = .init(headerType: .map)
                snapshot.appendSections([coordHeaderItem])
                return coordHeaderItem
            }
        }()
        
        let items: [DetailResultItem] = [
            .init(resultType: .map(latitude: latitude,
                                   longitude: longitude,
                                   locationTitle: addressDocumentData.address_name))
        ]
        
        snapshot.appendItems(items, toSection: coordHeaderItem)
        sortSnapshot(&snapshot)
        dataSource.apply(snapshot, animatingDifferences: false)
        refreshedEvent.send()
    }
    
    private func sortSnapshot(_ snapshot: inout Snapshot)  {
        var sectionIdentifiers: [DetailHeaderItem] = snapshot.sectionIdentifiers
        
        for a in 0..<sectionIdentifiers.count {
            for b in (a + 1)..<sectionIdentifiers.count {
                if (sectionIdentifiers[a].headerType.rawValue) > (sectionIdentifiers[b].headerType.rawValue) {
                    
                    snapshot.moveSection(sectionIdentifiers[b], beforeSection: sectionIdentifiers[a])
                    for c in (a + 1)..<b {
                        snapshot.moveSection(sectionIdentifiers[c], afterSection: sectionIdentifiers[c + 1])
                    }
                        
                    sectionIdentifiers.swapAt(a, b)
                }
            }
        }
    }
    
    private func checkBookmarkedStatus(data: BookmarksData = BookmarksService.shared.data) {
        guard let roadAddr: String = roadAddr else { return }
        bookmarkEvent.send(BookmarksService.shared.isBookmarked((roadAddr)))
    }
    
    private func bind() {
        addrAPIService.linkEvent
            .prefix(1)
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] data in
                guard let data: AddrLinkJusoData = data.juso.first else {
                    return
                }
                self?.loadData(data)
            })
            .store(in: &cancellableBag)
        
        addrAPIService.engEvent
            .prefix(1)
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] data in
                guard let engJusoData: AddrEngJusoData = data.juso.first else {
                    return
                }
                self?.updateEngItems(engJusoData)
            })
            .store(in: &cancellableBag)
        
        kakaoAPIService.addressEvent
            .prefix(1)
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] data in
                guard let addressDocumentData: KakaoAddressDocumentData = data.documents.first else {
                    return
                }
                self?.updateMapItems(addressDocumentData)
            })
            .store(in: &cancellableBag)
        
        BookmarksService.shared.dataEvent
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] data in
                self?.checkBookmarkedStatus(data: data)
            })
            .store(in: &cancellableBag)
    }
}
