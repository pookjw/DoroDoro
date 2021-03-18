//
//  SearchTableCellView.swift
//  DoroDoroMac
//
//  Created by Jinwoo Kim on 3/14/21.
//

import Cocoa
import Combine

class SearchTableCellView: NSView {

    @IBOutlet internal weak var imageView: NSImageView!
    @IBOutlet internal weak var textLabel: NSTextField!
    private var cancellableBag: Set<AnyCancellable> = .init()
    
    internal override func awakeFromNib() {
        super.awakeFromNib()
        setAttributes()
        bind()
    }
    
    private func setAttributes() {
        imageView.contentTintColor = NSColor.controlAccentColor
        
        if NSApplication.shared.isActive {
            textLabel.textColor = .labelColor
        } else {
            textLabel.textColor = .gray
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
                self?.textLabel?.textColor = .labelColor
            })
            .store(in: &cancellableBag)
        
        NotificationCenter.default
            .publisher(for: NSApplication.didResignActiveNotification)
            .sink(receiveValue: { [weak self] _ in
                self?.textLabel?.textColor = .gray
            })
            .store(in: &cancellableBag)
    }
    
}
