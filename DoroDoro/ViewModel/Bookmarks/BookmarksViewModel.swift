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
    internal typealias Snapshot = NSDiffableDataSourceSnapshot<BookmarksHeaderItem, BookmarksCellItem>
    internal var dataSource: DataSource? = nil
    @Published internal var searchEvent: String? = nil
    internal var contextMenuIndexPath: IndexPath? = nil
    internal var contextMenuRoadAddr: String? = nil
    internal var refreshEvent: PassthroughSubject<Bool, Never> = .init()
    private var cancellableBag: Set<AnyCancellable> = .init()
    
    internal init() {
        bind()
    }
    
    internal func getCellItem(from indexPath: IndexPath) -> BookmarksCellItem? {
        guard let items: [BookmarksCellItem] = dataSource?.snapshot().itemIdentifiers,
              items.count > indexPath.row else {
            return nil
        }
        return items[indexPath.row]
    }
    
    private func updateCellItems(_ bookmarksData: BookmarksData, searchText: String? = nil) {
        guard var snapshot: Snapshot = dataSource?.snapshot() else {
            return
        }
        
        let headerItem: BookmarksHeaderItem = {
            if let headerItem: BookmarksHeaderItem = snapshot.sectionIdentifiers.first {
                return headerItem
            } else {
                let headerItem: BookmarksHeaderItem = .init()
                return headerItem
            }
        }()
        
        let items: [BookmarksCellItem] = bookmarksData.bookmarkedRoadAddrs
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
        
        snapshot.deleteAllItems()
        snapshot.appendSections([headerItem])
        snapshot.appendItems(items, toSection: headerItem)
        dataSource?.apply(snapshot, animatingDifferences: true)
        refreshEvent.send(!items.isEmpty)
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
