//
//  DetailTableCellView.swift
//  DoroDoroMac
//
//  Created by Jinwoo Kim on 3/20/21.
//

import Cocoa
import Combine

internal final class DetailTableCellView: NSView {
    @IBOutlet private weak var imageView: NSImageView!
    @IBOutlet private weak var mainTextLabel: NSTextField!
    @IBOutlet private weak var subTextLabel: NSTextField!
    @IBOutlet private weak var mainStackViewWidthLayout: NSLayoutConstraint!
    private var cancellableBag: Set<AnyCancellable> = .init()
    
    internal var chageUIWhenActiveAppStatusChanged: Bool = false {
        didSet {
            if chageUIWhenActiveAppStatusChanged {
                if NSApp.isActive {
                    whenBecomeActive()
                } else {
                    whenResignActive()
                }
            } else {
                whenBecomeActive()
            }
        }
    }
    
    internal override func awakeFromNib() {
        super.awakeFromNib()
        setAttributes()
        bind()
    }
    
    internal func configure(mainText: String, subText: String, width: CGFloat) {
        mainTextLabel.stringValue = mainText
        subTextLabel.stringValue = subText
        updateWidthConstraint(width: width)
    }
    
    private func setAttributes() {
        imageView.contentTintColor = NSColor.controlAccentColor
        imageView.wantsLayer = true
        
        subTextLabel.maximumNumberOfLines = 0
        if NSApp.isActive {
            whenBecomeActive()
        } else {
            whenResignActive()
        }
    }
    
    private func bind() {
        NotificationCenter.default
            .publisher(for: NSApplication.didBecomeActiveNotification)
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] _ in
                guard let self = self,
                      self.chageUIWhenActiveAppStatusChanged else {
                    return
                }
                
                self.whenBecomeActive()
            })
            .store(in: &cancellableBag)
        
        NotificationCenter.default
            .publisher(for: NSApplication.didResignActiveNotification)
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] _ in
                guard let self = self,
                      self.chageUIWhenActiveAppStatusChanged else {
                    return
                }
                self.whenResignActive()
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
    
    private func updateWidthConstraint(width: CGFloat) {
        // 50을 빼서 크기를 여유롭게 잡아준다
        mainStackViewWidthLayout.constant = width - 50
    }
}
