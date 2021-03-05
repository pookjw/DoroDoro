//
//  AddrEngCommonData.swift
//  DoroDoro
//
//  Created by Jinwoo Kim on 2/26/21.
//

import Foundation

public struct AddrEngCommonData: Decodable {
    /// 총 검색 데이터수
    public let totalCount: String
    
    /// 페이지 번호
    public let currentPage: String
    
    /// 페이지당 출력할 결과 Row 수
    public let countPerPage: String
    
    /// 에러 코드
    public let errorCode: String
    
    /// 에러 메시지
    public let errorMessage: String
}
