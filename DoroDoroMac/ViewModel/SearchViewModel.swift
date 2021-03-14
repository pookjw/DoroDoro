//
//  SearchViewModel.swift
//  DoroDoroMac
//
//  Created by Jinwoo Kim on 3/14/21.
//

import Foundation
import Combine
import DoroDoroMacAPI

internal final class SearchViewModel {
    
    @Published internal var searchEvent: String? = nil
    internal let addrLinkJusoDataEvent: PassthroughSubject<(data: [AddrLinkJusoData], text: String), Never> = .init()
    internal private(set) var addrLinkJusoData: [AddrLinkJusoData] = []
    internal let addrAPIService: AddrAPIService = .init()
    
    private var currentPage: Int = 1
    private var totalCount: Int = 1
    private let countPerPage: Int = 50
    private var canLoadMore: Bool {
        let maxPage: Int = totalCount.isMultiple(of: countPerPage) ? (totalCount / countPerPage) : (totalCount / countPerPage + 1)
        return currentPage < maxPage
    }
    private var cancellableBag: Set<AnyCancellable> = .init()
    
    internal init() {
        bind()
    }
    
    internal func requestNextPageIfAvailable() {
        
    }
    
    private func bind() {
        $searchEvent
            .sink(receiveValue: { [weak self] text in
                guard let self = self else { return }
                guard let text: String = text,
                      !text.isEmpty else { return }
                self.currentPage = 1
                self.addrAPIService.requestLinkEvent(keyword: text, currentPage: self.currentPage, countPerPage: self.countPerPage)
            })
            .store(in: &cancellableBag)
        
        addrAPIService
            .linkEvent
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] data in
                guard !data.juso.isEmpty else {
                    self?.addrAPIService.linkErrorEvent.send(.noResults)
                    return
                }
                self?.addrLinkJusoDataEvent.send((data: data.juso, text: self?.searchEvent ?? ""))
            })
            .store(in: &cancellableBag)
        
        addrLinkJusoDataEvent
            .sink(receiveValue: { [weak self] (data, _) in
                self?.addrLinkJusoData = data
            })
            .store(in: &cancellableBag)
    }
}
