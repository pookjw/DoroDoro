//
//  String+wrap.swift
//  DoroDoro
//
//  Created by Jinwoo Kim on 4/3/21.
//

import Foundation

extension Optional where Wrapped == String {
    internal func wrappedNoData() -> String {
        return self?.wrappedNoData() ?? Localizable.NO_DATA.string
    }
    
    internal func wrappedBdKdcd() -> String {
        return self?.wrappedBdKdcd() ?? Localizable.NO_DATA.string
    }
    
    internal func wrappedUdrtYn() -> String {
        return self?.wrappedUdrtYn() ?? Localizable.NO_DATA.string
    }
    
    internal func wrappedMtYn(_ mtYn: String?) -> String {
        return self?.wrappedMtYn() ?? Localizable.NO_DATA.string
    }
}

extension String {
    internal func wrappedNoData() -> String {
        return self.isEmpty ? Localizable.NO_DATA.string : self
    }
    
    internal func wrappedBdKdcd() -> String {
        return (self == "0") ? "비공동주택" : "공동주택"
    }
    
    internal func wrappedUdrtYn() -> String {
        return (self == "0") ? "지상" : "지하"
    }
    
    internal func wrappedMtYn() -> String {
        return (self == "0") ? "대지" : "산"
    }
}
