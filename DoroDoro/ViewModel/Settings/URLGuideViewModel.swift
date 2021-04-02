//
//  URLGuideViewModel.swift
//  DoroDoro
//
//  Created by Jinwoo Kim on 4/2/21.
//

import UIKit

internal final class URLGuideViewModel {
    internal typealias DataSource = UICollectionViewDiffableDataSource<URLGuideHeaderItem, URLGuideCellItem>
    private typealias Snapshot = NSDiffableDataSourceSnapshot<URLGuideHeaderItem, URLGuideCellItem>
    
    private var dataSource: DataSource
    
    internal init(dataSource: DataSource) {
        self.dataSource = dataSource
        updateCellItems()
    }
    
    internal func getCellItem(from indexPath: IndexPath) -> URLGuideCellItem? {
        let sectionIdentifiers: [URLGuideHeaderItem] = dataSource.snapshot().sectionIdentifiers
        
        guard sectionIdentifiers.count > indexPath.section else {
            return nil
        }
        
        let cellItems: [URLGuideCellItem] = dataSource.snapshot().itemIdentifiers(inSection: sectionIdentifiers[indexPath.section])
        
        guard cellItems.count > indexPath.row else {
            return nil
        }
        
        return cellItems[indexPath.row]
    }
    
    internal func getHeaderItem(from indexPath: IndexPath) -> URLGuideHeaderItem? {
        let sectionIdentifiers: [URLGuideHeaderItem] = dataSource.snapshot().sectionIdentifiers
        guard sectionIdentifiers.count > indexPath.section else {
            return nil
        }
        return sectionIdentifiers[indexPath.section]
    }
    
    private func updateCellItems() {
        var snapshot: Snapshot = dataSource.snapshot()
        snapshot.deleteAllItems()
        
        let searchHeaderItem: URLGuideHeaderItem = .init(headerType: .search)
        let searchWithTextHeaderItem: URLGuideHeaderItem = .init(headerType: .searchWithText)
        let searchCurrentLocationHeaderItem: URLGuideHeaderItem = .init(headerType: .searchCurrentLocation)
        let bookmarksHeaderItem: URLGuideHeaderItem = .init(headerType: .bookmarks)
        snapshot.appendSections([searchHeaderItem, searchWithTextHeaderItem, searchCurrentLocationHeaderItem, bookmarksHeaderItem])
        
        let searchCellItem: URLGuideCellItem = .init(cellType: .search)
        let searchWithTextCellItem: URLGuideCellItem = .init(cellType: .searchWithText)
        let searchCurrentLocationCellItem: URLGuideCellItem = .init(cellType: .searchCurrentLocation)
        let bookmarksCellItem: URLGuideCellItem = .init(cellType: .bookmarks)
        
        snapshot.appendItems([searchCellItem], toSection: searchHeaderItem)
        snapshot.appendItems([searchWithTextCellItem], toSection: searchWithTextHeaderItem)
        snapshot.appendItems([searchCurrentLocationCellItem], toSection: searchCurrentLocationHeaderItem)
        snapshot.appendItems([bookmarksCellItem], toSection: bookmarksHeaderItem)
        
        dataSource.apply(snapshot)
    }
}
