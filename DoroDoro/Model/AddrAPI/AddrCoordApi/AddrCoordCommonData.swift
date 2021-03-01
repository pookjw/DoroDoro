//
//  AddrCoordCommonData.swift
//  DoroDoro
//
//  Created by Jinwoo Kim on 3/1/21.
//

import Foundation

internal struct AddrCoordCommonData: Decodable {
    /// 총 검색 데이터수
    internal let totalCount: String
    
    /// 에러 코드
    internal let errorCode: String
    
    /// 에러 메시지
    internal let errorMessage: String
}
