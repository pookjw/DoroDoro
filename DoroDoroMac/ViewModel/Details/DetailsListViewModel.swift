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
}
