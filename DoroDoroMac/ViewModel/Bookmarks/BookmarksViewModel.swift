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
    internal let refreshedEvent: CurrentValueSubject<(data: [String], hasData: Bool, hasResult: Bool?), Never> = .init((data: [], hasData: false, hasResult: nil))
    internal private(set) var bookmarksData: [String] = []
    private var cancellableBag: Set<AnyCancellable> = .init()
    
    internal init() {
        bind()
    }
    
    private func updateBookmarksData(_ bookmarksData: BookmarksData, searchText: String? = nil) {
        
        let originalItems: [String: Date] = bookmarksData.bookmarkedRoadAddrs
        
        let filteredItems: [String] = originalItems
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
        
        refreshedEvent.send((data: filteredItems, hasData: hasData, hasResult: hasResult))
    }
    
    private func bind() {
        BookmarksService.shared.dataEvent
            .combineLatest($searchEvent)
            .sink(receiveValue: { [weak self] (data, text) in
                self?.updateBookmarksData(data, searchText: text)
            })
            .store(in: &cancellableBag)
        
        refreshedEvent
            .sink(receiveValue: { [weak self] (data, _, _) in
                self?.bookmarksData = data
            })
            .store(in: &cancellableBag)
    }
}
