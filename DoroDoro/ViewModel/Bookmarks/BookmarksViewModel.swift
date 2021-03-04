//
//  BookmarksViewModel.swift
//  DoroDoro
//
//  Created by Jinwoo Kim on 3/4/21.
//

import Foundation
import UIKit
import Combine

final internal class BookmarksViewModel {
    internal typealias DataSource = UICollectionViewDiffableDataSource<BookmarksHeaderItem, BookmarksCellItem>
    internal typealias Snapshot = NSDiffableDataSourceSnapshot<BookmarksHeaderItem, BookmarksCellItem>
    internal var dataSource: DataSource? = nil
    private var cancellableBag: Set<AnyCancellable> = .init()
    
    internal init() {
        bind()
    }
    
    private func updateCellItems(_ bookmarksData: BookmarksData) {
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
            .sorted { first, second in
                return first.value > second.value
            }
            .map { (roadAddr, _) -> BookmarksCellItem in
                return .init(roadAddr: roadAddr)
            }
        
        snapshot.deleteAllItems()
        snapshot.appendSections([headerItem])
        snapshot.appendItems(items, toSection: headerItem)
        dataSource?.apply(snapshot, animatingDifferences: true)
    }
    
    private func bind() {
        BookmarksService.shared.dataEvent
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] data in
                self?.updateCellItems(data)
            })
            .store(in: &cancellableBag)
    }
}
