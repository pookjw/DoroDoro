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
        
        let activityIndicatorView: NVActivityIndicatorView = .init(frame: CGRect(x: 0, y: 0, width: 200, height: 200),
                                                                   type: .circleStrokeSpin,
                                                                   color: .white,
                                                                   padding: 50)
        self.activityIndicatorView = activityIndicatorView
        addSubview(activityIndicatorView)
        activityIndicatorView.translatesAutoresizingMaskIntoConstraints = false
        activityIndicatorView.snp.remakeConstraints { make in
            make.centerX.equalToSuperview()
            make.centerY.equalToSuperview()
            make.width.equalTo(200)
            make.height.equalTo(200)
        }
        activityIndicatorView.backgroundColor = UIColor.gray.withAlphaComponent(0.75)
        activityIndicatorView.layer.cornerRadius = 30
        activityIndicatorView.startAnimating()
    }
}
