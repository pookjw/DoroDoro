//
//  SearchResultObject.swift
//  DoroDoroWatch Extension
//
//  Created by Jinwoo Kim on 3/6/21.
//

import WatchKit

internal final class SearchResultObject: NSObject {
    @IBOutlet weak internal var label: WKInterfaceLabel!
    
    internal func configure(data: AddrLinkJusoData) {
        label.setText(data.roadAddr)
    }
}
