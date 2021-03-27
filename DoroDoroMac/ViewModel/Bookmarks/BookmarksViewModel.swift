//
//  BookmarksViewModel.swift
//  DoroDoroMac
//
//  Created by Jinwoo Kim on 3/22/21.
//

import Cocoa
import Combine
import DoroDoroMacAPI

internal final class BookmarksViewModel {
    /*
     Swift struct로 구현된 놈은 버그가 있길래... Objective-C로 된거롤 쓴다. (macOS 11.2.3, 11.3 기준)
     */
    internal typealias DataSource = NSTableViewDiffableDataSourceReference<BookmarksHeaderItem, BookmarksCellItem>
    private typealias Snapshot = NSDiffableDataSourceSnapshotReference
    
    @Published internal var searchEvent: String? = nil
    internal var dataSource: DataSource
    internal let refreshedEvent: CurrentValueSubject<(hasData: Bool, hasResult: Bool?), Never> = .init((hasData: false, hasResult: nil))
    private var cancellableBag: Set<AnyCancellable> = .init()
    
    internal init(dataSource: DataSource) {
        self.dataSource = dataSource
        bind()
    }
    
    internal func getCellItem(row: Int) -> BookmarksCellItem? {
        guard let items: [BookmarksCellItem] = dataSource.snapshot().itemIdentifiers as? [BookmarksCellItem],
              (row >= 0 && items.count > row) else {
            return nil
        }
        return items[row]
    }
    
    internal func getCelltems() -> [BookmarksCellItem]? {
        return dataSource.snapshot().itemIdentifiers as? [BookmarksCellItem]
    }
    
    private func updateBookmarksData(_ bookmarksData: BookmarksData, searchText: String? = nil) {
        let snapshot: Snapshot = dataSource.snapshot()
        
        let headerItem: BookmarksHeaderItem = {
            if let headerItem: BookmarksHeaderItem = snapshot.sectionIdentifiers.first as? BookmarksHeaderItem {
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
        snapshot.appendSections(withIdentifiers: [headerItem])
        snapshot.appendItems(withIdentifiers: filteredItems, intoSectionWithIdentifier: headerItem)
        // macOS 버그 때문인지 animatingDifferences을 true로 하면 간혹 런타임 크래시
        dataSource.applySnapshot(snapshot, animatingDifferences: false)
        
        refreshedEvent.send((hasData: hasData, hasResult: hasResult))
    }
    
    private func bind() {
        BookmarksService.shared.dataEvent
            .combineLatest($searchEvent)
            .sink(receiveValue: { [weak self] (data, text) in
                self?.updateBookmarksData(data, searchText: text)
            })
            .store(in: &cancellableBag)
    }
}
