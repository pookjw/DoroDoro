//
//  BookmarksViewModel.swift
//  DoroDoro
//
//  Created by Jinwoo Kim on 3/4/21.
//

import UIKit
import Combine

internal final class BookmarksViewModel {
    internal typealias DataSource = UICollectionViewDiffableDataSource<BookmarksHeaderItem, BookmarksCellItem>
    private typealias Snapshot = NSDiffableDataSourceSnapshot<BookmarksHeaderItem, BookmarksCellItem>
    internal var dataSource: DataSource
    @Published internal var searchEvent: String? = nil
    internal var contextMenuIndexPath: IndexPath? = nil
    internal var contextMenuRoadAddr: String? = nil
    internal var refreshEvent: PassthroughSubject<(hasData: Bool, hasResult: Bool?), Never> = .init()
    private var cancellableBag: Set<AnyCancellable> = .init()
    
    internal init(dataSource: DataSource) {
        self.dataSource = dataSource
        bind()
    }
    
    internal func getCellItem(from indexPath: IndexPath) -> BookmarksCellItem? {
        let items: [BookmarksCellItem] = dataSource.snapshot().itemIdentifiers
        
        guard items.count > indexPath.row else {
            return nil
        }
        
        return items[indexPath.row]
    }
    
    private func updateCellItems(_ bookmarksData: BookmarksData, searchText: String? = nil) {
        var snapshot: Snapshot = dataSource.snapshot()
        
        let headerItem: BookmarksHeaderItem = {
            if let headerItem: BookmarksHeaderItem = snapshot.sectionIdentifiers.first {
                return headerItem
            } else {
                let headerItem: BookmarksHeaderItem = .init()
                return headerItem
            }
        }()
        
        let originalItems: [String: Date] = bookmarksData.bookmarkedRoadAddrs
        
        let filteredItems: [BookmarksCellItem] = originalItems
            .filter({ (roadAddr, _) in
                guard let text: String = searchText,
                      !text.isEmpty else {
                    return true
                }
                return roadAddr.contains(text) || roadAddr.choseongContains(text)
            })
            .sorted { (first, second) in
                return first.value > second.value
            }
            .map { (roadAddr, _) -> BookmarksCellItem in
                return .init(roadAddr: roadAddr)
            }
        
        let hasData: Bool = !filteredItems.isEmpty
        
        let hasResult: Bool? = {
            // 책갈피 데이터 자체가 없을 경우
            guard !originalItems.isEmpty else {
                return nil
            }
            
            // 검색 모드가 아닐 경우
            guard let text: String = searchText,
                  !text.isEmpty else {
                return nil
            }
            
            return !filteredItems.isEmpty
        }()
        
        snapshot.deleteAllItems()
        snapshot.appendSections([headerItem])
        snapshot.appendItems(filteredItems, toSection: headerItem)
        dataSource.apply(snapshot, animatingDifferences: true)
        refreshEvent.send((hasData: hasData, hasResult: hasResult))
    }
    
    private func bind() {
        BookmarksService.shared.dataEvent
            .combineLatest($searchEvent)
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] (data, text) in
                self?.updateCellItems(data, searchText: text)
            })
            .store(in: &cancellableBag)
    }
}
