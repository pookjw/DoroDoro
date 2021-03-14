//
//  NSViewController+SpinnerView.swift
//  DoroDoroMac
//
//  Created by Jinwoo Kim on 3/14/21.
//

import Cocoa
import SnapKit

extension NSViewController {
    @discardableResult
    internal func showSpinnerView() -> SpinnerView {
        let spinnerView: SpinnerView = .init()
        spinnerView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(spinnerView)
        spinnerView.snp.remakeConstraints { $0.edges.equalToSuperview() }
        return spinnerView
    }
    
    internal func removeAllSpinnerView() {
        findSpinnerView().forEach { [weak self] spinnerView in
            self?.removeSpinnerView(spinnerView)
        }
    }
    
    internal func removeSpinnerView(_ spinnerView: SpinnerView) {
        spinnerView.removeFromSuperview()
    }
    
    private func findSpinnerView() -> [SpinnerView] {
        return view.subviews.compactMap { $0 as? SpinnerView }
    }
}
