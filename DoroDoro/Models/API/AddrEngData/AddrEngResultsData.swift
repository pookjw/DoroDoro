//
//  AddrEngResultsData.swift
//  DoroDoro
//
//  Created by Jinwoo Kim on 2/26/21.
//

import Foundation

public struct AddrEngResultsData: Decodable {
    public let common: AddrEngCommonData
    public let juso: [AddrEngJusoData]
}
