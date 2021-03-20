//
//  SearchTableCellView.swift
//  DoroDoroMac
//
//  Created by Jinwoo Kim on 3/14/21.
//

import Cocoa
import Combine

class SearchTableCellView: NSView {

    @IBOutlet private weak var imageView: NSImageView!
    @IBOutlet private weak var textLabel: NSTextField!
    private var cancellableBag: Set<AnyCancellable> = .init()
    
    internal override func awakeFromNib() {
        super.awakeFromNib()
        setAttributes()
        bind()
    }
    
    internal func configure(text: String) {
        textLabel.stringValue = text
    }
    
    private func setAttributes() {
        imageView.contentTintColor = NSColor.controlAccentColor
        imageView.wantsLayer = true
        
        if NSApplication.shared.isActive {
            whenBecomeActive()
        } else {
            whenResignActive()
        }
    }
    
    private func bind() {
        // 굳이 이거 안해줘도 자동으로 되더라...
//        NotificationCenter.default
//            .publisher(for: NSColor.systemColorsDidChangeNotification)
//            .sink(receiveValue: { [weak self] notification in
//                guard let color: NSColor = notification.object as? NSColor else {
//                    return
//                }
//                self?.imageView.contentTintColor = color
//            })
//            .store(in: &cancellableBag)
        
        NotificationCenter.default
            .publisher(for: NSApplication.didBecomeActiveNotification)
            .sink(receiveValue: { [weak self] _ in
                self?.whenBecomeActive()
            })
            .store(in: &cancellableBag)
        
        NotificationCenter.default
            .publisher(for: NSApplication.didResignActiveNotification)
            .sink(receiveValue: { [weak self] _ in
                self?.whenResignActive()
            })
            .store(in: &cancellableBag)
    }
    
    private func whenBecomeActive() {
        imageView?.layer?.opacity = 1
        textLabel?.textColor = .labelColor
    }
    
    private func whenResignActive() {
        imageView?.layer?.opacity = 0.5
        textLabel?.textColor = .gray
    }
}
