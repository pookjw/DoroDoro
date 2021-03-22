//
//  SpinnerView.swift
//  DoroDoroMac
//
//  Created by Jinwoo Kim on 3/14/21.
//

import Cocoa
import SnapKit
import ITProgressIndicator

internal final class SpinnerView: NSView {
    private weak var backgroundView: NSView? = nil
    private weak var progressIndicator: ITProgressIndicator? = nil

    internal override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)
        setAttributes()
    }
    
    private func setAttributes() {
        wantsLayer = true
        
        let backgroundView: NSView = .init()
        self.backgroundView = backgroundView
        backgroundView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(backgroundView)
        backgroundView.snp.remakeConstraints { make in
            make.center.equalToSuperview()
            make.width.equalTo(150)
            make.height.equalTo(150)
        }
        backgroundView.wantsLayer = true
        backgroundView.layer?.cornerRadius = 30
        
        //
        
        let progressIndicator: ITProgressIndicator = .init(frame: .init(x: 0, y: 0, width: 110, height: 110))
        self.progressIndicator = progressIndicator
        progressIndicator.isIndeterminate = true
        progressIndicator.lengthOfLine = 30
        progressIndicator.numberOfLines = 12
        progressIndicator.innerMargin = 10
        progressIndicator.translatesAutoresizingMaskIntoConstraints = false
        backgroundView.addSubview(progressIndicator)
        progressIndicator.snp.remakeConstraints { make in
            make.center.equalToSuperview()
            make.width.equalTo(110)
            make.height.equalTo(110)
        }
        
        viewDidChangeEffectiveAppearance()
    }
    
    internal override func viewDidChangeEffectiveAppearance() {
        guard let backgroundView: NSView = backgroundView,
              let progressIndicator: ITProgressIndicator = progressIndicator else {
            return
        }

        if NSApp.isDarkAquaMode {
            backgroundView.layer?.backgroundColor = NSColor.white.cgColor
            progressIndicator.color = .black
        } else {
            backgroundView.layer?.backgroundColor = NSColor.black.cgColor
            progressIndicator.color = .white
        }
    }
}
