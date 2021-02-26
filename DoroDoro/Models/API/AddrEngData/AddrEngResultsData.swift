//
//  AddrEngResultsData.swift
//  DoroDoro
//
//  Created by Jinwoo Kim on 2/26/21.
//

import Foundation

public struct AddrEngResultsData: Decodable {
    /// 검색 결과 정보를 담고 있다.
    public let common: AddrEngCommonData
    
    /// 영문주소 정보를 담고 있다.
    ///
    /// Error가 나올 경우 null이 나오므로 Optional이 되어야 함
    public let juso: [AddrEngJusoData]?
}
