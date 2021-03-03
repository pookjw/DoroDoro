//
//  SearchViewModel.swift
//  DoroDoro
//
//  Created by Jinwoo Kim on 2/28/21.
//

import Foundation
import UIKit
import Combine

final internal class SearchViewModel {
    internal typealias DataSource = UICollectionViewDiffableDataSource<SearchHeaderItem, SearchResultItem>
    internal typealias Snapshot = NSDiffableDataSourceSnapshot<SearchHeaderItem, SearchResultItem>
    
    internal var contextMenuLinkJusoData: AddrLinkJusoData? = nil
    internal let addrAPIService: AddrAPIService = .init()
    internal var dataSource: DataSource? = nil
    internal var refreshedEvent: PassthroughSubject<Bool, Never> = .init()
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
    
    internal func updateResultItems(_ result: AddrLinkResultsData, text: String) {
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
                snapshot.deleteAllItems()
                
                let headerItem: SearchHeaderItem = .init(title: String(format: Localizable.RESULTS_FOR_ADDRESS.string, text))
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
        refreshedEvent.send(canLoadMore)
    }
    
    private func bind() {
        $searchEvent
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
    }
}
