//
//  DetailsViewController.swift
//  DoroDoroMac
//
//  Created by Jinwoo Kim on 3/19/21.
//

import Cocoa
import Combine
import SnapKit

internal final class DetailsViewController: NSViewController {
    private weak var visualEffectView: NSVisualEffectView? = nil
    
    internal override func loadView() {
        let view: NSView = .init()
        self.view = view
    }
    
    internal override func viewDidLoad() {
        super.viewDidLoad()
        configureVisualEffectView()
    }
    
    private func configureVisualEffectView() {
        let visualEffectView: NSVisualEffectView = .init()
        self.visualEffectView = visualEffectView
        visualEffectView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(visualEffectView)
        visualEffectView.snp.remakeConstraints { $0.edges.equalToSuperview() }
    }
}
