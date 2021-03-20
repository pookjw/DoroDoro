//
//  DetailsTableCellView.swift
//  DoroDoroMac
//
//  Created by Jinwoo Kim on 3/20/21.
//

import Cocoa
import Combine

internal final class DetailsTableCellView: NSView {
    @IBOutlet weak var imageView: NSImageView!
    @IBOutlet weak var mainTextLabel: NSTextField!
    @IBOutlet weak var subTextLabel: NSTextField!
    private var cancellableBag: Set<AnyCancellable> = .init()
    
    internal override func awakeFromNib() {
        super.awakeFromNib()
        setAttributes()
        bind()
    }
    
    internal func configure(mainText: String, subText: String) {
        mainTextLabel.stringValue = mainText
        subTextLabel.stringValue = subText
    }
    
    private func setAttributes() {
        imageView.contentTintColor = NSColor.controlAccentColor
        imageView.wantsLayer = true
        
        
//        mainTextLabel.number
//        subTextLabel.maximumNumberOfLines = 0
        subTextLabel.maximumNumberOfLines = 0
        if NSApplication.shared.isActive {
            whenBecomeActive()
        } else {
            whenResignActive()
        }
    }
    
    private func bind() {
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
        mainTextLabel?.textColor = .labelColor
        subTextLabel?.textColor = .labelColor
    }
    
    private func whenResignActive() {
        imageView?.layer?.opacity = 0.5
        mainTextLabel?.textColor = .gray
        subTextLabel?.textColor = .gray
    }
}
