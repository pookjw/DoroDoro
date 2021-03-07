//
//  SearchViewModel.swift
//  DoroDoro
//
//  Created by Jinwoo Kim on 2/28/21.
//

import UIKit
import Combine
import DoroDoroAPI

final internal class SearchViewModel {
    internal typealias DataSource = UICollectionViewDiffableDataSource<SearchHeaderItem, SearchResultItem>
    internal typealias Snapshot = NSDiffableDataSourceSnapshot<SearchHeaderItem, SearchResultItem>
    
    internal var contextMenuIndexPath: IndexPath? = nil
    internal var contextMenuLinkJusoData: AddrLinkJusoData? = nil
    internal let addrAPIService: AddrAPIService = .init()
    internal let geoAPIService: GeoAPIService = .init()
    internal let kakaoAPIService: KakaoAPIService = .init()
    internal var dataSource: DataSource? = nil
    internal let refreshedEvent: PassthroughSubject<(canLoadMore: Bool, hasData: Bool, isFirstPage: Bool), Never> = .init()
    internal let geoEvent: PassthroughSubject<String, Never> = .init()
    internal private(set) var isGeoSearching: Bool = false
    @Published internal var searchEvent: String? = nil
    
    private var currentPage: Int = 1
    private var totalCount: Int = 1
    private var canLoadMore: Bool {
        let maxPage: Int = totalCount.isMultiple(of: 50) ? (totalCount / 50) : (totalCount / 50 + 1)
        return currentPage < maxPage
    }
    private var cancellableBag: Set<AnyCancellable> = .init()
    
    internal init() {
        bind()
    }
    
    internal func requestGeoEvent() {
        isGeoSearching = true
        geoAPIService.requestCurrentCoord()
    }
    
    internal func requestNextPageIfAvailable() {
        guard canLoadMore else {
            return
        }
        
        guard let text: String = searchEvent,
              !text.isEmpty else { return }
        currentPage += 1
        addrAPIService.requestLinkEvent(keyword: text, currentPage: currentPage, countPerPage: 50)
    }
    
    internal func getResultItem(from indexPath: IndexPath) -> SearchResultItem? {
        guard let items: [SearchResultItem] = dataSource?.snapshot().itemIdentifiers,
              items.count > indexPath.row else {
            return nil
        }
        return items[indexPath.row]
    }
    
    private func updateResultItems(_ result: AddrLinkResultsData, text: String) {
        totalCount = Int(result.common.totalCount) ?? 1
        
        guard var snapshot: Snapshot = dataSource?.snapshot() else {
            return
        }
        
        let headerItem: SearchHeaderItem = {
            // 이미 기존에 생성된 Header가 있고, 1페이지가 아닌 경우 기존 Header를 그대로 쓴다.
            if let headerItem: SearchHeaderItem = snapshot.sectionIdentifiers.first,
               currentPage != 1 {
                return headerItem
            } else {
                // 기존에 생성된 Header가 없거나 1페이지일 경우 Header를 새로 만든다.
                let headerItem: SearchHeaderItem = .init(title: String(format: Localizable.RESULTS_FOR_ADDRESS.string, text))
                snapshot.deleteAllItems()
                snapshot.appendSections([headerItem])
                
                return headerItem
            }
        }()
        
        var items: [SearchResultItem] = []
        result.juso.forEach { data in
            let result: SearchResultItem = .init(linkJusoData: data)
            items.append(result)
        }
        
        snapshot.appendItems(items, toSection: headerItem)
        dataSource?.apply(snapshot, animatingDifferences: true)
        refreshedEvent.send((canLoadMore: canLoadMore, hasData: !items.isEmpty, isFirstPage: currentPage == 1))
    }
    
    private func bind() {
        $searchEvent
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] text in
                guard let self = self else { return }
                guard let text: String = text,
                      !text.isEmpty else { return }
                self.currentPage = 1
                self.addrAPIService.requestLinkEvent(keyword: text, currentPage: self.currentPage, countPerPage: 50)
            })
            .store(in: &cancellableBag)
        
        addrAPIService.linkEvent
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] result in
                self?.updateResultItems(result, text: self?.searchEvent ?? "")
            })
            .store(in: &cancellableBag)
        
        geoAPIService.coordEvent
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] coord in
                self?.kakaoAPIService.requestCoord2AddressEvent(x: String(coord.longitude), y: String(coord.latitude))
            })
            .store(in: &cancellableBag)
        
        kakaoAPIService.coord2AddressEvent
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] data in
                defer {
                    self?.isGeoSearching = false
                }
                
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
        
        kakaoAPIService.coord2AddressErrorEvent
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] error in
                self?.isGeoSearching = false
            })
            .store(in: &cancellableBag)
    }
}
