//
//  SpinnerView.swift
//  DoroDoro
//
//  Created by Jinwoo Kim on 3/1/21.
//

import UIKit
import SnapKit
import NVActivityIndicatorView

final internal class SpinnerView: UIView {
    private weak var blurView: UIVisualEffectView? = nil
    private weak var activityIndicatorView: NVActivityIndicatorView? = nil
    
    internal init() {
        super.init(frame: .zero)
        setAttributes()
        configureAccessiblity()
    }
    
    required internal init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override internal func removeFromSuperview() {
        activityIndicatorView?.stopAnimating()
        activityIndicatorView?.removeFromSuperview()
        super.removeFromSuperview()
    }
    
    
    override internal func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        
        activityIndicatorView?.stopAnimating()
        
        if traitCollection.userInterfaceStyle == .dark {
            blurView?.effect = UIBlurEffect(style: .extraLight)
            activityIndicatorView?.color = .black
        } else {
            blurView?.effect = UIBlurEffect(style: .dark)
            activityIndicatorView?.color = .white
        }
        
        activityIndicatorView?.startAnimating()
    }
    
    private func setAttributes() {
        backgroundColor = .clear
        isUserInteractionEnabled = true
        
        //
        
        let blurView: UIVisualEffectView = .init()
        self.blurView = blurView
        addSubview(blurView)
        blurView.translatesAutoresizingMaskIntoConstraints = false
        blurView.snp.remakeConstraints { make in
            make.centerX.equalToSuperview()
            make.centerY.equalToSuperview()
            make.width.equalTo(150)
            make.height.equalTo(150)
        }
        blurView.layer.cornerRadius = 30
        blurView.clipsToBounds = true
        blurView.isUserInteractionEnabled = false
        
        //
        
        let activityIndicatorView: NVActivityIndicatorView = .init(frame: CGRect(x: 0, y: 0, width: 150, height: 150),
                                                                   type: .circleStrokeSpin,
                                                                   padding: 40)
        self.activityIndicatorView = activityIndicatorView
        blurView.contentView.addSubview(activityIndicatorView)
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
        blurView?.contentView.accessibilityLabel = Localizable.ACCESSIBILITY_LOADING_CONENTS.string
        blurView?.contentView.isAccessibilityElement = true
        activityIndicatorView?.accessibilityLabel = Localizable.ACCESSIBILITY_LOADING_CONENTS.string
        activityIndicatorView?.isAccessibilityElement = true
    }
}
