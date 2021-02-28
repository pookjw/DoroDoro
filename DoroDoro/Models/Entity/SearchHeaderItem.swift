//
//  SearchHeaderItem.swift
//  DoroDoro
//
//  Created by Jinwoo Kim on 2/28/21.
//

import Foundation

public struct SearchHeaderItem: Hashable {
    public let title: String
    public let results: [SearchResultItem]
}
