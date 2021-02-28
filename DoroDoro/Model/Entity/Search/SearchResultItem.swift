//
//  SearchResultItem.swift
//  DoroDoro
//
//  Created by Jinwoo Kim on 2/28/21.
//

import Foundation

internal struct SearchResultItem: Hashable, Equatable {
    internal let linkJusoData: AddrLinkJusoData
    private let id = UUID()
    
    internal static func == (lhs: SearchResultItem, rhs: SearchResultItem) -> Bool {
        return lhs.id == rhs.id
    }
}
