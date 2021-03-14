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
    internal let addrLinkJusoDataEvent: PassthroughSubject<(data: [AddrLinkJusoData], text: String, isFirstPage: Bool), Never> = .init()
    internal private(set) var addrLinkJusoData: [AddrLinkJusoData] = []
    internal let addrAPIService: AddrAPIService = .init()
    
    private var currentPage: Int = 1
    private var totalCount: Int = 1
    private let countPerPage: Int = 50
    private var canLoadMore: Bool {
        let maxPage: Int = totalCount.isMultiple(of: countPerPage) ? (totalCount / countPerPage) : (totalCount / countPerPage + 1)
        return currentPage < maxPage
    }
    private var isLoading: Bool = false
    private var cancellableBag: Set<AnyCancellable> = .init()
    
    internal init() {
        bind()
    }
    
    @discardableResult
    internal func requestNextPageIfAvailable() -> Bool {
        guard canLoadMore && !isLoading else {
            return false
        }
        
        guard let text: String = searchEvent,
              !text.isEmpty else { return false }
        currentPage += 1
        isLoading = true
        addrAPIService.requestLinkEvent(keyword: text, currentPage: currentPage, countPerPage: countPerPage)
        return true
    }
    
    private func bind() {
        $searchEvent
            .sink(receiveValue: { [weak self] text in
                guard let self = self else { return }
                guard !self.isLoading else { return }
                guard let text: String = text,
                      !text.isEmpty else { return }
                self.currentPage = 1
                self.isLoading = true
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
                self?.isLoading = false
                self?.updateJusoData(data)
            })
            .store(in: &cancellableBag)
        
        addrAPIService
            .linkErrorEvent
            .sink(receiveValue: { [weak self] _ in
                self?.isLoading = false
            })
            .store(in: &cancellableBag)
        
        addrLinkJusoDataEvent
            .sink(receiveValue: { [weak self] (data, _, _) in
                self?.addrLinkJusoData = data
            })
            .store(in: &cancellableBag)
    }
    
    private func updateJusoData(_ data: AddrLinkResultsData) {
        totalCount = Int(data.common.totalCount) ?? 1
        
        //
        
        var newJusoData: [AddrLinkJusoData] = addrLinkJusoData
        if currentPage == 1 {
            newJusoData = data.juso
        } else {
            newJusoData.append(contentsOf: data.juso)
        }
        addrLinkJusoDataEvent.send((data: newJusoData, text: searchEvent ?? "", isFirstPage: currentPage == 1))
    }
}
