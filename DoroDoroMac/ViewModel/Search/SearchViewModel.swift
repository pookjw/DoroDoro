//
//  SearchViewModel.swift
//  DoroDoroMac
//
//  Created by Jinwoo Kim on 3/14/21.
//

import Cocoa
import Combine
import DoroDoroMacAPI

internal final class SearchViewModel {
    /*
     Swift struct로 구현된 놈은 버그가 있길래... Objective-C로 된거롤 쓴다. (macOS 11.2.3, 11.3 기준)
     */
    internal typealias DataSource = NSTableViewDiffableDataSourceReference<SearchHeaderItem, SearchResultItem>
    private typealias Snapshot = NSDiffableDataSourceSnapshotReference
    internal var dataSource: DataSource? = nil
    @Published internal var searchEvent: String? = nil
    internal let refreshedEvent: PassthroughSubject<(text: String, hasData: Bool, isFirstPage: Bool), Never> = .init()
    internal let addrAPIService: AddrAPIService = .init()
    
    private var currentPage: Int = 1
    private var totalCount: Int = 1
    private let countPerPage: Int = 50
    private var canLoadMore: Bool {
        let maxPage: Int = totalCount.isMultiple(of: countPerPage) ? (totalCount / countPerPage) : (totalCount / countPerPage + 1)
        return currentPage < maxPage
    }
    private var isLoading: Bool = false
    private var cancellableBag: Set<AnyCancellable> = .init()
    
    internal init() {
        bind()
    }
    
    internal func getResultItem(row: Int) -> SearchResultItem? {
        guard let items: [SearchResultItem] = dataSource?.snapshot().itemIdentifiers as? [SearchResultItem],
              (row >= 0 && items.count > row) else {
            return nil
        }
        return items[row]
    }
    
    internal func getResultItems() -> [SearchResultItem]? {
        return dataSource?.snapshot().itemIdentifiers as? [SearchResultItem]
    }
    
    @discardableResult
    internal func requestNextPageIfAvailable() -> Bool {
        guard canLoadMore && !isLoading else {
            return false
        }
        
        guard let text: String = searchEvent,
              !text.isEmpty else { return false }
        currentPage += 1
        isLoading = true
        addrAPIService.requestLinkEvent(keyword: text, currentPage: currentPage, countPerPage: countPerPage)
        return true
    }
    
    private func bind() {
        $searchEvent
            .sink(receiveValue: { [weak self] text in
                guard let self = self else { return }
                guard !self.isLoading else { return }
                guard let text: String = text,
                      !text.isEmpty else { return }
                self.currentPage = 1
                self.isLoading = true
                self.addrAPIService.requestLinkEvent(keyword: text, currentPage: self.currentPage, countPerPage: self.countPerPage)
            })
            .store(in: &cancellableBag)
        
        addrAPIService
            .linkEvent
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] data in
                guard !data.juso.isEmpty else {
                    self?.addrAPIService.linkErrorEvent.send(.noResults)
                    return
                }
                self?.isLoading = false
                self?.updateJusoData(data, text: self?.searchEvent ?? "")
            })
            .store(in: &cancellableBag)
        
        addrAPIService
            .linkErrorEvent
            .sink(receiveValue: { [weak self] _ in
                self?.isLoading = false
            })
            .store(in: &cancellableBag)
    }
    
    private func updateJusoData(_ result: AddrLinkResultsData, text: String) {
        guard let snapshot: Snapshot = dataSource?.snapshot() else {
            return
        }
        
        totalCount = Int(result.common.totalCount) ?? 1
        
        let headerItem: SearchHeaderItem = {
            // 이미 기존에 생성된 Header가 있고, 1페이지가 아닌 경우 기존 Header를 그대로 쓴다.
            if let headerItem: SearchHeaderItem = snapshot.sectionIdentifiers.first as? SearchHeaderItem,
               currentPage != 1 {
                return headerItem
            } else {
                // 기존에 생성된 Header가 없거나 1페이지일 경우 Header를 새로 만든다.
                let headerItem: SearchHeaderItem = .init(title: String(format: Localizable.RESULTS_FOR_ADDRESS.string, text))
                snapshot.deleteAllItems()
                snapshot.appendSections(withIdentifiers: [headerItem])
                
                return headerItem
            }
        }()
        
        let items: [SearchResultItem] = result.juso
            .map { data -> SearchResultItem in
                let result: SearchResultItem = .init(linkJusoData: data)
                return result
            }
        
        snapshot.appendItems(withIdentifiers: items, intoSectionWithIdentifier: headerItem)
        dataSource?.applySnapshot(snapshot, animatingDifferences: true)
        refreshedEvent.send((text: searchEvent ?? "",hasData: !items.isEmpty, isFirstPage: currentPage == 1))
    }
}
