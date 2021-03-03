//
//  SettingsService.swift
//  DoroDoro
//
//  Created by Jinwoo Kim on 3/4/21.
//

import Foundation
import Combine

final internal class SettingsService {
    // MARK: - Internal Properties
    static internal let shared: SettingsService = .init()
    internal let dataEvent: AnyPublisher<SettingsData, Never>
    
    // MARK: - Private Properties
    private let _dataEvent: PassthroughSubject<SettingsData, Never> = .init()
    private var cancellableBag: Set<AnyCancellable> = .init()
    private struct Constants {
        static fileprivate let settingsKey: String = "settings"
    }
    
    // MARK: - Private Methods
    private init() {
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
        if let dic: [String: Any] = CloudService.shared.keyValueStore.dictionary(forKey: Constants.settingsKey) {
            _dataEvent.send(SettingsData(dic: dic))
        } else {
            _dataEvent.send(SettingsData())
        }
    }
}
