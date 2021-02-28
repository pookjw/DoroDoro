//
//  SearchViewModel.swift
//  DoroDoro
//
//  Created by Jinwoo Kim on 2/28/21.
//

import Foundation
import UIKit
import Combine

final class SearchViewModel {
    typealias DataSource = UICollectionViewDiffableDataSource<SearchHeaderItem, SearchResultItem>
    typealias Snapshot = NSDiffableDataSourceSnapshot<SearchHeaderItem, SearchResultItem>
    
    public var dataSource: DataSource! = nil
    public var refreshedEvent: PassthroughSubject<Bool, Never> = .init()
    @Published public var searchEvent: String? = nil
    
    private var currentPage: Int = 1
    private var totalCount: Int = 1
    private var canLoadMore: Bool {
        let maxPage: Int = totalCount.isMultiple(of: 50) ? (totalCount / 50) : (totalCount / 50 + 1)
        return currentPage < maxPage
    }
    
    private var cancellableBag: Set<AnyCancellable> = .init()
    
    public init() {
        bind()
    }
    
    public func requestNextPageIfAvailable() {
        guard canLoadMore else {
            return
        }
        
        guard let text: String = searchEvent,
              !text.isEmpty else { return }
        currentPage += 1
        APIService.shared.requestAddrLinkEvent(keyword: text, currentPage: currentPage, countPerPage: 50)
    }
    
    private func updateResultItems(_ result: AddrLinkResultsData, text: String) {
        totalCount = Int(result.common.totalCount) ?? 1
        
        var snapshot: Snapshot = dataSource.snapshot()
        
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
            let result: SearchResultItem = .init(title: data.roadAddr)
            items.append(result)
        }
        
        snapshot.appendItems(items, toSection: headerItem)
        dataSource.apply(snapshot, animatingDifferences: true)
        refreshedEvent.send(canLoadMore)
    }
    
    private func bind() {
        $searchEvent
            .sink(receiveValue: { [weak self] text in
                guard let self = self else { return }
                guard let text: String = text,
                      !text.isEmpty else { return }
                self.currentPage = 1
                APIService.shared.requestAddrLinkEvent(keyword: text, currentPage: self.currentPage, countPerPage: 50)
            })
            .store(in: &cancellableBag)
        
        APIService.shared.addrLinkEvent
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] result in
                self?.updateResultItems(result, text: self?.searchEvent ?? "")
            })
            .store(in: &cancellableBag)
    }
}
