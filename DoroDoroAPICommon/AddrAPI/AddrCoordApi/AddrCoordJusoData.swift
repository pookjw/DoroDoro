//
//  AddrCoordJusoData.swift
//  DoroDoro
//
//  Created by Jinwoo Kim on 3/1/21.
//

import Foundation

public struct AddrCoordJusoData: Decodable {
    /// 행정구역코드
    public let admCd: String
    
    /// 도로명코드
    public let rnMgtSn: String
    
    /// 건물관리번호
    public let bdMgtSn: String
    
    /// 지하여부
    ///
    /// - `0` : 지상
    /// - `1` : 지하
    public let udrtYn: String
    
    /// 건물본번
    public let buldMnnm: String
    
    /// 건물부번
    public let buldSlno: String
    
    /// X좌표
    public let entX: String
    
    /// Y좌표
    public let entY: String
    
    /// 건물명
    public let bdNm: String
}

extension AddrCoordJusoData: Equatable {
    public static func == (lhs: AddrCoordJusoData, rhs: AddrCoordJusoData) -> Bool {
        return (lhs.entX == rhs.entX) && (lhs.entY == rhs.entY)
    }
}
