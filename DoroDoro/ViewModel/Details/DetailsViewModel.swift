//
//  DetailsViewModel.swift
//  DoroDoro
//
//  Created by Jinwoo Kim on 3/1/21.
//

import Foundation
import Combine

final internal class DetailsViewModel {
    internal typealias DataSource = UICollectionViewDiffableDataSource<DetailHeaderItem, DetailResultItem>
    internal typealias Snapshot = NSDiffableDataSourceSnapshot<DetailHeaderItem, DetailResultItem>
    
    internal var dataSource: DataSource? = nil
    /// 전체 도로명주소
    internal var roadAddr: String? = nil
    internal var linkJusoData: AddrLinkJusoData? = nil
    internal var refreshedEvent: PassthroughSubject<Void, Never> = .init()
    internal let addrAPIService: AddrAPIService = .init()
    internal let kakaoAPIService: KakaoAPIService = .init()
    private var engJusoData: AddrEngJusoData? = nil
    private var addressDocumentData: KakaoAddressDocumentData? = nil
    private var cancellableBag: Set<AnyCancellable> = .init()
    
    internal init() {
        bind()
    }
    
    internal func getResultItem(from indexPath: IndexPath) -> DetailResultItem? {
        guard let sectionIdentifiers: [DetailHeaderItem] = dataSource?.snapshot().sectionIdentifiers else {
            return nil
        }
        
        guard sectionIdentifiers.count > indexPath.section else {
            return nil
        }
        
        guard let resultItems: [DetailResultItem] = dataSource?.snapshot().itemIdentifiers(inSection: sectionIdentifiers[indexPath.section]) else {
            return nil
        }
        
        guard resultItems.count > indexPath.row else {
            return nil
        }
        
        return resultItems[indexPath.row]
    }
    
    internal func getSectionHeaderType(from indexPath: IndexPath) -> DetailHeaderItem.HeaderType? {
        guard let sectionIdentifiers: [DetailHeaderItem] = dataSource?.snapshot().sectionIdentifiers else {
            return nil
        }
        guard sectionIdentifiers.count > indexPath.section else {
            return nil
        }
        return sectionIdentifiers[indexPath.section].headerType
    }
    
    internal func loadData() {
        if let linkJusoData: AddrLinkJusoData = linkJusoData {
            deleteAllItems()
            roadAddr = linkJusoData.roadAddr
            updateLinkItems()
            addrAPIService.requestEngEvent(keyword: linkJusoData.roadAddr)
            kakaoAPIService.requestAddressEvent(query: linkJusoData.roadAddr,
                                                analyzeType: .exact, page: 1, size: 1)
        } else if let roadAddr: String = roadAddr {
            deleteAllItems()
            addrAPIService.requestLinkEvent(keyword: roadAddr)
        }
    }
    
    private func deleteAllItems() {
        guard var snapshot: Snapshot = dataSource?.snapshot() else {
            return
        }
        snapshot.deleteAllItems()
        dataSource?.apply(snapshot, animatingDifferences: true)
    }
    
    private func updateLinkItems() {
        guard var snapshot: Snapshot = dataSource?.snapshot(),
            let linkJusoData: AddrLinkJusoData = linkJusoData else {
            return
        }
        
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
            .init(resultType: .link(text: "전체 도로명주소", secondaryText: wrappedNoData(linkJusoData.roadAddr))),
            .init(resultType: .link(text: "도로명주소", secondaryText: wrappedNoData(linkJusoData.roadAddrPart1))),
            .init(resultType: .link(text: "도로명주소 참고항목", secondaryText: wrappedNoData(linkJusoData.roadAddrPart2))),
            .init(resultType: .link(text: "지번주소", secondaryText: wrappedNoData(linkJusoData.jibunAddr))),
            .init(resultType: .link(text: "우편번호", secondaryText: wrappedNoData(linkJusoData.zipNo))),
            .init(resultType: .link(text: "행정구역코드", secondaryText: wrappedNoData(linkJusoData.admCd))),
            .init(resultType: .link(text: "도로명코드", secondaryText: wrappedNoData(linkJusoData.rnMgtSn))),
            .init(resultType: .link(text: "건물관리번호", secondaryText: wrappedNoData(linkJusoData.bdMgtSn))),
            .init(resultType: .link(text: "상세건물명", secondaryText: wrappedNoData(linkJusoData.detBdNmList))),
            .init(resultType: .link(text: "건물명", secondaryText: wrappedNoData(linkJusoData.bdNm))),
            .init(resultType: .link(text: "공동주택여부", secondaryText: wrappedBdKdcd(linkJusoData.bdKdcd))),
            .init(resultType: .link(text: "시도명", secondaryText: wrappedNoData(linkJusoData.siNm))),
            .init(resultType: .link(text: "시군구명", secondaryText: wrappedNoData(linkJusoData.sggNm))),
            .init(resultType: .link(text: "읍면동명", secondaryText: wrappedNoData(linkJusoData.emdNm))),
            .init(resultType: .link(text: "법정리명", secondaryText: wrappedNoData(linkJusoData.liNm))),
            .init(resultType: .link(text: "도로명", secondaryText: wrappedNoData(linkJusoData.rn))),
            .init(resultType: .link(text: "지하여부", secondaryText: wrappedUdrtYn(linkJusoData.udrtYn))),
            .init(resultType: .link(text: "건물본번", secondaryText: wrappedNoData(linkJusoData.buldMnnm))),
            .init(resultType: .link(text: "건물부번", secondaryText: wrappedNoData(linkJusoData.buldSlno))),
            .init(resultType: .link(text: "산여부", secondaryText: wrappedMtYn(linkJusoData.mtYn))),
            .init(resultType: .link(text: "지번본번(번지)", secondaryText: wrappedNoData(linkJusoData.lnbrMnnm))),
            .init(resultType: .link(text: "지번부번(호)", secondaryText: wrappedNoData(linkJusoData.lnbrSlno))),
            .init(resultType: .link(text: "읍면동일련번호", secondaryText: wrappedNoData(linkJusoData.emdNo))),
            .init(resultType: .link(text: "관련지번", secondaryText: wrappedNoData(linkJusoData.relJibun))),
            .init(resultType: .link(text: "관할주민센터(참고정보)", secondaryText: wrappedNoData(linkJusoData.hemdNm)))
        ]
        
        snapshot.appendItems(items, toSection: linkHeaderItem)
        sortSnapshot(&snapshot)
        dataSource?.apply(snapshot, animatingDifferences: true)
        refreshedEvent.send()
    }
    
    private func updateEngItems() {
        guard var snapshot: Snapshot = dataSource?.snapshot(),
            let engJusoData: AddrEngJusoData = engJusoData else {
            return
        }
        
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
            .init(resultType: .eng(text: "영문 도로명주소", secondaryText: wrappedNoData(engJusoData.roadAddr))),
            .init(resultType: .eng(text: "영문 지번주소", secondaryText: wrappedNoData(engJusoData.jibunAddr))),
            .init(resultType: .eng(text: "영문 시도명", secondaryText: wrappedNoData(engJusoData.siNm))),
            .init(resultType: .eng(text: "영문 시군구명", secondaryText: wrappedNoData(engJusoData.sggNm))),
            .init(resultType: .eng(text: "영문 읍면동명", secondaryText: wrappedNoData(engJusoData.emdNm))),
            .init(resultType: .eng(text: "영문 법정리명", secondaryText: wrappedNoData(engJusoData.liNm))),
            .init(resultType: .eng(text: "영문 도로명", secondaryText: wrappedNoData(engJusoData.rn)))
        ]
        
        snapshot.appendItems(items, toSection: engHeaderItem)
        sortSnapshot(&snapshot)
        dataSource?.apply(snapshot, animatingDifferences: false)
        refreshedEvent.send()
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
        dataSource?.apply(snapshot, animatingDifferences: false)
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
        addrAPIService.linkEvent
            .prefix(1)
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] data in
                self?.linkJusoData = data.juso.first
                self?.loadData()
            })
            .store(in: &cancellableBag)
        
        addrAPIService.engEvent
            .prefix(1)
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] data in
                self?.engJusoData = data.juso.first
                self?.updateEngItems()
            })
            .store(in: &cancellableBag)
        
        kakaoAPIService.addressEvent
            .prefix(1)
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] data in
                self?.addressDocumentData = data.documents.first
                self?.updateMapItems()
            })
            .store(in: &cancellableBag)
    }
}
