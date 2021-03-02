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
        configure()
    }
    
    required internal init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override internal func removeFromSuperview() {
        activityIndicatorView?.stopAnimating()
        activityIndicatorView?.removeFromSuperview()
        super.removeFromSuperview()
    }
    
    private func configure() {
        backgroundColor = .clear
        isUserInteractionEnabled = true
        
        let blurView: UIVisualEffectView = .init(effect: UIBlurEffect(style: .dark))
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
        
        let activityIndicatorView: NVActivityIndicatorView = .init(frame: CGRect(x: 0, y: 0, width: 150, height: 150),
                                                                   type: .circleStrokeSpin,
                                                                   color: .white,
                                                                   padding: 40)
        self.activityIndicatorView = activityIndicatorView
        blurView.contentView.addSubview(activityIndicatorView)
        activityIndicatorView.translatesAutoresizingMaskIntoConstraints = false
        activityIndicatorView.snp.remakeConstraints { make in
            make.edges.equalToSuperview()
        }
        activityIndicatorView.backgroundColor = .clear
        activityIndicatorView.isUserInteractionEnabled = false
        activityIndicatorView.startAnimating()
    }
}
