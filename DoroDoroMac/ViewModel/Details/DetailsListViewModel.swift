//
//  DetailsListViewModel.swift
//  DoroDoroMac
//
//  Created by Jinwoo Kim on 3/27/21.
//

import Cocoa

internal final class DetailsListViewModel {
    /*
     Swift struct로 구현된 놈은 버그가 있길래... Objective-C로 된거롤 쓴다. (macOS 11.2.3, 11.3 기준)
     */
    internal typealias DataSource = NSTableViewDiffableDataSourceReference<DetailsListHeaderItem, DetailsListResultItem>
    private typealias Snapshot = NSDiffableDataSourceSnapshotReference
    private var dataSource: DataSource
    
    internal init(dataSource: DataSource) {
        self.dataSource = dataSource
    }
    
    internal func updateResultItems(_ resultItems: [DetailsListResultItem]) {
        let snapshot: Snapshot = dataSource.snapshot()
        
        let headerItem: DetailsListHeaderItem = {
            // 이미 기존에 생성된 Header가 있는 경우 그대로 쓴다.
            if let headerItem: DetailsListHeaderItem = snapshot.sectionIdentifiers.first as? DetailsListHeaderItem {
                return headerItem
            } else {
                // 기존에 생성된 Header가 없거나 1페이지일 경우 Header를 새로 만든다.
                let headerItem: DetailsListHeaderItem = .init()
                snapshot.deleteAllItems()
                snapshot.appendSections(withIdentifiers: [headerItem])
                
                return headerItem
            }
        }()
        
        snapshot.appendItems(withIdentifiers: resultItems, intoSectionWithIdentifier: headerItem)
        // macOS 버그 때문인지 animatingDifferences을 true로 하면 간혹 런타임 크래시
        dataSource.applySnapshot(snapshot, animatingDifferences: false)
    }
}
