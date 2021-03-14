//
//  UIViewController+SpinnerView.swift
//  DoroDoro
//
//  Created by Jinwoo Kim on 3/3/21.
//

import UIKit
import SnapKit

extension UIViewController {
    /// SpinnerView를 보여준다.
    ///
    /// - Parameters :
    ///     - fadeAnimated : SpinnerView를 띄울 때의 Fade Animation
    @discardableResult
    internal func showSpinnerView(fadeAnimated: Bool = true) -> SpinnerView {
        let spinnerView: SpinnerView = .init()
        spinnerView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(spinnerView)
        spinnerView.snp.remakeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        if fadeAnimated {
            spinnerView.layer.opacity = 0
            UIView.animate(withDuration: 0.3) { [weak spinnerView] in
                spinnerView?.layer.opacity = 1
            }
        } else {
            spinnerView.layer.opacity = 1
        }
        
        return spinnerView
    }
    
    /// 모든 SpinnerView를 삭제한다.
    ///
    /// - Parameters:
    ///     - fadeAnimated : SpinnerView를 삭제할 때의 Fade Animation
    internal func removeAllSpinnerView(fadeAnimated: Bool = true) {
        findSpinnerView().forEach { [weak self] spinnerView in
            self?.removeSpinnerView(spinnerView, fadeAnimated: fadeAnimated)
        }
    }
    
    /// SpinnerView를 삭제한다.
    ///
    /// - Parameters:
    ///     - spinnerView: 삭제할 SpinnerView
    ///     - fadeAnimated : SpinnerView를 삭제할 때의 Fade Animation
    internal func removeSpinnerView(_ spinnerView: SpinnerView, fadeAnimated: Bool = true) {
        if fadeAnimated {
            UIView.animate(withDuration: 0.3, animations: { [weak spinnerView] in
                spinnerView?.layer.opacity = 0
            }, completion: { [weak spinnerView] _ in
                spinnerView?.removeFromSuperview()
            })
        } else {
            spinnerView.removeFromSuperview()
        }
    }
    
    private func findSpinnerView() -> [SpinnerView] {
        return view.subviews.compactMap { $0 as? SpinnerView }
    }
}
