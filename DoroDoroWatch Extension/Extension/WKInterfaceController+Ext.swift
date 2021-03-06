//
//  WKInterfaceController+Ext.swift
//  DoroDoroWatch Extension
//
//  Created by Jinwoo Kim on 3/6/21.
//

import WatchKit

extension WKInterfaceController {
    internal func showErrorAlert(for error: Error) {
        let message: String?
        if let error: LocalizedError = error as? LocalizedError {
            message = error.errorDescription
        } else {
            message = error.localizedDescription
        }
        
        let doneAction: WKAlertAction = .init(title: Localizable.DONE.string,
                                              style: .default) {}
        presentAlert(withTitle: "ERROR!(번역필요)",
                           message: message,
                           preferredStyle: .alert,
                           actions: [doneAction])
    }
    
    internal func startLoadingAnimation(in imageView: WKInterfaceImage, with closure: (() -> Void)? = nil) {
        closure?()
        imageView.setImageNamed("Animation")
        imageView.startAnimatingWithImages(in: NSRange(location: 0, length: 23), duration: 1, repeatCount: 0)
    }
    
    internal func stopLoadingAnimation(in imageView: WKInterfaceImage, with closure: (() -> Void)? = nil) {
        closure?()
        imageView.stopAnimating()
        imageView.setImageNamed(nil)
    }
}
