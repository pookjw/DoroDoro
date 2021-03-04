//
//  BookmarksService.swift
//  DoroDoro
//
//  Created by Jinwoo Kim on 3/4/21.
//

import Foundation
import Combine

final internal class BookmarksService {
    // MARK: - Internal Properties
    static internal let shared: BookmarksService = .init()
    internal let dataEvent: AnyPublisher<BookmarksData, Never>
    internal var data: BookmarksData {
        return _dataEvent.value
    }
    
    // MARK: - Internal Properties
    internal func save(_ data: BookmarksData) {
        _dataEvent.send(data)
        CloudService.shared.keyValueStore.set(data.bookmarkedRoadAddrs, forKey: Constants.bookmarksKey)
        CloudService.shared.synchronize()
    }
    
    internal func isBookmarked(_ roadAddr: String) -> Bool {
        data.bookmarkedRoadAddrs.keys.contains(roadAddr)
    }
    
    internal func removeBookmark(_ roadAddr: String) {
        var data: BookmarksData = self.data
        data.bookmarkedRoadAddrs.removeValue(forKey: roadAddr)
        save(data)
    }
    
    internal func addBookmark(_ roadAddr: String) {
        var data: BookmarksData = self.data
        data.bookmarkedRoadAddrs[roadAddr] = Date()
        save(data)
    }
    
    internal func toggleBookmark(_ roadAddr: String) {
        if isBookmarked(roadAddr) {
            removeBookmark(roadAddr)
        } else {
            addBookmark(roadAddr)
        }
    }
    
    // MARK: - Private Properties
    private let _dataEvent: CurrentValueSubject<BookmarksData, Never>
    private var cancellableBag: Set<AnyCancellable> = .init()
    private struct Constants {
        static fileprivate let bookmarksKey: String = "bookmarks"
    }
    
    private init() {
        if let dic: [String: Date] = CloudService.shared.keyValueStore.dictionary(forKey: Constants.bookmarksKey) as? [String: Date] {
            _dataEvent = .init(.init(dic: dic))
        } else {
            _dataEvent = .init(.init())
        }
        
        dataEvent = _dataEvent
            .removeDuplicates()
            .eraseToAnyPublisher()
        
        bind()
    }
    
    private func bind() {
        CloudService.shared.didChangeEvent
            .sink(receiveValue: { [weak self] _ in
                self?.fetchData()
            })
            .store(in: &cancellableBag)
    }
    
    private func fetchData() {
        if let dic: [String: Date] = CloudService.shared.keyValueStore.dictionary(forKey: Constants.bookmarksKey) as? [String: Date] {
            _dataEvent.send(.init(dic: dic))
        } else {
            _dataEvent.send(.init())
        }
    }
}
