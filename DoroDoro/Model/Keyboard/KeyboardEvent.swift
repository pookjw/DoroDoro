//
//  KeyboardEvent.swift
//  DoroDoro
//
//  Created by Jinwoo Kim on 3/7/21.
//

import UIKit
import Combine

final internal class KeyboardEvent {
    static internal let shared: KeyboardEvent = .init()
    internal let attributesEvent: PassthroughSubject<(height: CGFloat, duration: Float), Never> = .init()
    
    internal init() {
        bind()
    }
    
    private var cancellableBag: Set<AnyCancellable> = .init()
    
    private func whenReceivedEvent(_ notification: Notification, hide: Bool) {
        if let keyboardFrame: NSValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue,
           let keyboardAnimationDuration: NSNumber = notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? NSNumber {
            let keyboardRectangle: CGRect = keyboardFrame.cgRectValue
            let keyboardHeight: CGFloat = hide ? 0 : keyboardRectangle.height
            let keyboardDuration: Float = keyboardAnimationDuration.floatValue
            attributesEvent.send((height: keyboardHeight, duration: keyboardDuration))
        }
    }
    
    private func bind() {
        NotificationCenter
            .default
            .publisher(for: UIResponder.keyboardWillShowNotification, object: nil)
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] notification in
                self?.whenReceivedEvent(notification, hide: false)
            })
            .store(in: &cancellableBag)
        
        NotificationCenter
            .default
            .publisher(for: UIResponder.keyboardWillHideNotification, object: nil)
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] notification in
                self?.whenReceivedEvent(notification, hide: true)
            })
            .store(in: &cancellableBag)
    }
}
