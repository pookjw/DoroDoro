//
//  CloudService.swift
//  DoroDoro
//
//  Created by Jinwoo Kim on 3/4/21.
//

import Foundation
import Combine

final internal class CloudService {
    // MARK: - Internal Properties
    static internal let shared: CloudService = .init()
    internal let didChangeEvent: AnyPublisher<[AnyHashable: Any]?, Never>
    
    internal let keyValueStore: NSUbiquitousKeyValueStore = .default
    
    // MARK: - Internal Properties
    @discardableResult
    internal func synchronize() -> Bool {
        return keyValueStore.synchronize()
    }
    
    // MARK: - Private Properties
    private let _didChangeEvent: PassthroughSubject<[AnyHashable: Any]?, Never> = .init()
    private var cancellableBag: Set<AnyCancellable> = .init()
    
    // MARK: - Private Methods
    private init() {
        didChangeEvent = _didChangeEvent
            .share()
            .eraseToAnyPublisher()
        
        bind()
    }
    
    private func bind() {
        NotificationCenter
            .default
            .publisher(for: NSUbiquitousKeyValueStore.didChangeExternallyNotification, object: keyValueStore)
            .sink(receiveValue: { [weak self] notification in
                self?._didChangeEvent.send(notification.userInfo)
            })
            .store(in: &cancellableBag)
    }
}
