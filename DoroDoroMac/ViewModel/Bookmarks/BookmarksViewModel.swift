//
//  BookmarksViewModel.swift
//  DoroDoroMac
//
//  Created by Jinwoo Kim on 3/22/21.
//

import Foundation
import Combine
import DoroDoroMacAPI

internal final class BookmarksViewModel {
    @Published internal var searchEvent: String? = nil
    internal let refreshedEvent: CurrentValueSubject<(data: [String], hasData: Bool), Never> = .init((data: [], hasData: false))
    internal private(set) var bookmarksData: [String] = []
    private var cancellableBag: Set<AnyCancellable> = .init()
    
    internal init() {
        bind()
    }
    
    private func updateBookmarksData(_ bookmarksData: BookmarksData, searchText: String? = nil) {
        let items: [String] = bookmarksData.bookmarkedRoadAddrs
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
            .map { (roadAddr, _) -> String in
                return roadAddr
            }
        
        refreshedEvent.send((data: items, hasData: !items.isEmpty))
    }
    
    private func bind() {
        BookmarksService.shared.dataEvent
            .combineLatest($searchEvent)
            .sink(receiveValue: { [weak self] (data, text) in
                self?.updateBookmarksData(data, searchText: text)
            })
            .store(in: &cancellableBag)
        
        refreshedEvent
            .sink(receiveValue: { [weak self] (data, _) in
                self?.bookmarksData = data
            })
            .store(in: &cancellableBag)
    }
}
