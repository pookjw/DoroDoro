//
//  AddrLinkResultsData.swift
//  DoroDoro
//
//  Created by Jinwoo Kim on 2/26/21.
//

import Foundation

public struct AddrLinkResultsData: Decodable {
    public let common: AddrLinkCommonData
    public let juso: [AddrLinkJusoData]
}
