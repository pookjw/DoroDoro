//
//  SearchInterfaceModel.swift
//  DoroDoroWatch Extension
//
//  Created by Jinwoo Kim on 3/6/21.
//

import Foundation
import Combine
import DoroDoroWatchAPI

final internal class SearchInterfaceModel {
    internal let linkJusoDataEvent: PassthroughSubject<([AddrLinkJusoData], String), Never> = .init()
    @Published internal var searchEvent: String? = nil
    internal let addrAPIService: AddrAPIService = .init()
    internal var linkJusoData: [AddrLinkJusoData] = []
    private var cancellableBag: Set<AnyCancellable> = .init()
    
    internal init() {
        bind()
    }
    
    private func bind() {
        $searchEvent
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] text in
                guard let text: String = text,
                      !text.isEmpty else { return }
                self?.addrAPIService.requestLinkEvent(keyword: text, countPerPage: 50)
            })
            .store(in: &cancellableBag)
        
        addrAPIService.linkEvent
            .receive(on: DispatchQueue.main)
            .sink { [weak self] data in
                self?.linkJusoData = data.juso
                self?.linkJusoDataEvent.send((data.juso, self?.searchEvent ?? ""))
            }
            .store(in: &cancellableBag)
    }
}
