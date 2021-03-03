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
    
    private func bind() {
        
    }
}
