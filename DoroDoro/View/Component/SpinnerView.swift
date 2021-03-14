//
//  SpinnerView.swift
//  DoroDoro
//
//  Created by Jinwoo Kim on 3/1/21.
//

import UIKit
import SnapKit
import NVActivityIndicatorView

internal final class SpinnerView: UIView {
    private weak var visualEffectView: UIVisualEffectView? = nil
    private weak var activityIndicatorView: NVActivityIndicatorView? = nil
    
    internal init() {
        super.init(frame: .zero)
        setAttributes()
        configureAccessiblity()
    }
    
    internal required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    internal override func removeFromSuperview() {
        activityIndicatorView?.stopAnimating()
        activityIndicatorView?.removeFromSuperview()
        super.removeFromSuperview()
    }
    
    
    internal override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        
        activityIndicatorView?.stopAnimating()
        
        if traitCollection.userInterfaceStyle == .dark {
            visualEffectView?.effect = UIBlurEffect(style: .extraLight)
            activityIndicatorView?.color = .black
        } else {
            visualEffectView?.effect = UIBlurEffect(style: .dark)
            activityIndicatorView?.color = .white
        }
        
        activityIndicatorView?.startAnimating()
    }
    
    private func setAttributes() {
        backgroundColor = .clear
        isUserInteractionEnabled = true
        
        //
        
        let visualEffectView: UIVisualEffectView = .init()
        self.visualEffectView = visualEffectView
        addSubview(visualEffectView)
        visualEffectView.translatesAutoresizingMaskIntoConstraints = false
        visualEffectView.snp.remakeConstraints { make in
            make.center.equalToSuperview()
            make.width.equalTo(150)
            make.height.equalTo(150)
        }
        visualEffectView.layer.cornerRadius = 30
        visualEffectView.clipsToBounds = true
        visualEffectView.isUserInteractionEnabled = false
        
        //
        
        let activityIndicatorView: NVActivityIndicatorView = .init(frame: CGRect(x: 0, y: 0, width: 150, height: 150),
                                                                   type: .circleStrokeSpin,
                                                                   padding: 40)
        self.activityIndicatorView = activityIndicatorView
        visualEffectView.contentView.addSubview(activityIndicatorView)
        activityIndicatorView.translatesAutoresizingMaskIntoConstraints = false
        activityIndicatorView.snp.remakeConstraints { make in
            make.edges.equalToSuperview()
        }
        activityIndicatorView.backgroundColor = .clear
        activityIndicatorView.isUserInteractionEnabled = false
        
        //
        
        traitCollectionDidChange(nil)
    }
    
    private func configureAccessiblity() {
        accessibilityLabel = Localizable.ACCESSIBILITY_LOADING_CONENTS.string
        isAccessibilityElement = true
        visualEffectView?.contentView.accessibilityLabel = Localizable.ACCESSIBILITY_LOADING_CONENTS.string
        visualEffectView?.contentView.isAccessibilityElement = true
        activityIndicatorView?.accessibilityLabel = Localizable.ACCESSIBILITY_LOADING_CONENTS.string
        activityIndicatorView?.isAccessibilityElement = true
    }
}
