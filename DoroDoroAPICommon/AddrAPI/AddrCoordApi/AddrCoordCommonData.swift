//
//  AddrCoordCommonData.swift
//  DoroDoro
//
//  Created by Jinwoo Kim on 3/1/21.
//

import Foundation

public struct AddrCoordCommonData: Decodable {
    /// 총 검색 데이터수
    public let totalCount: String
    
    /// 에러 코드
    public let errorCode: String
    
    /// 에러 메시지
    public let errorMessage: String
}
