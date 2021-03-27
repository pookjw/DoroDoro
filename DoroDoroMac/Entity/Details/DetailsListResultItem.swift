//
//  DetailsListResultItem.swift
//  DoroDoroMac
//
//  Created by Jinwoo Kim on 3/20/21.
//

import Foundation

internal final class DetailsListResultItem: NSObject {
    internal private(set) var text: String?
    internal private(set) var secondaryText: String?
    
    internal convenience init(text: String, secondaryText: String) {
        self.init()
        self.text = text
        self.secondaryText = secondaryText
    }
}
