//
//  AddrCoordJusoData.swift
//  DoroDoro
//
//  Created by Jinwoo Kim on 3/1/21.
//

import Foundation

internal struct AddrCoordJusoData: Decodable {
    /// 행정구역코드
    internal let admCd: String
    
    /// 도로명코드
    internal let rnMgtSn: String
    
    /// 건물관리번호
    internal let bdMgtSn: String
    
    /// 지하여부
    ///
    /// - `0` : 지상
    /// - `1` : 지하
    internal let udrtYn: String
    
    /// 건물본번
    internal let buldMnnm: String
    
    /// 건물부번
    internal let buldSlno: String
    
    /// X좌표
    internal let entX: String
    
    /// Y좌표
    internal let entY: String
    
    /// 건물명
    internal let bdNm: String
}

extension AddrCoordJusoData: Equatable {
    static internal func == (lhs: AddrCoordJusoData, rhs: AddrCoordJusoData) -> Bool {
        return (lhs.entX == rhs.entX) && (lhs.entY == rhs.entY)
    }
}
