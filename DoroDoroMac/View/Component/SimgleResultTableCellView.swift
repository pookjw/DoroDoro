//
//  SimgleResultTableCellView.swift
//  DoroDoroMac
//
//  Created by Jinwoo Kim on 3/14/21.
//

import Cocoa
import Combine

class SimgleResultTableCellView: NSView {
    @IBOutlet private weak var imageView: NSImageView!
    @IBOutlet private weak var textLabel: NSTextField!
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
    
    internal func configure(text: String, width: CGFloat) {
        textLabel.stringValue = text
        updateWidthConstraint(width: width)
    }
    
    private func setAttributes() {
        imageView.contentTintColor = NSColor.controlAccentColor
        imageView.wantsLayer = true
        
        if NSApp.isActive {
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
        textLabel?.textColor = .labelColor
    }
    
    private func whenResignActive() {
        imageView?.layer?.opacity = 0.5
        textLabel?.textColor = .gray
    }
    
    private func updateWidthConstraint(width: CGFloat) {
        // 50을 빼서 크기를 여유롭게 잡아준다
        mainStackViewWidthLayout.constant = width - 50
    }
}
