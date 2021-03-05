//
//  AddrCoordSearchData.swift
//  DoroDoro
//
//  Created by Jinwoo Kim on 3/1/21.
//

import Foundation

public struct AddrCoordSearchData {
    /// 행정구역코드
    public let admCd: String
    
    /// 도로명코드
    public let rnMgtSn: String
    
    /// 지하여부
    public let udrtYn: String
    
    /// 건물본번
    public let buldMnnm: String
    
    /// 건물부번
    public let buldSlno: String
    
    public init(admCd: String,
                rnMgtSn: String,
                udrtYn: String,
                buldMnnm: String,
                buldSlno: String) {
        self.admCd = admCd
        self.rnMgtSn = rnMgtSn
        self.udrtYn = udrtYn
        self.buldMnnm = buldMnnm
        self.buldSlno = buldSlno
    }
}
