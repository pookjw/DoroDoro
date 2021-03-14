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
    
    internal override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)
        imageView.contentTintColor = NSColor.controlAccentColor
        bind()
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
    }
}
