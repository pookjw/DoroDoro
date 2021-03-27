//
//  SearchResultItem.swift
//  DoroDoroMac
//
//  Created by Jinwoo Kim on 3/27/21.
//

import Foundation
import DoroDoroMacAPI

internal final class SearchResultItem: NSObject {
    internal private(set) var linkJusoData: AddrLinkJusoData? = nil
    
    internal convenience init(linkJusoData: AddrLinkJusoData) {
        self.init()
        self.linkJusoData = linkJusoData
    }
    
    private let id: UUID = .init()
    
    internal override func isEqual(_ object: Any?) -> Bool {
        guard let object: SearchResultItem = object as? SearchResultItem else {
            return false
        }
        return self.id == object.id
    }
}
