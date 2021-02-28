//
//  AddrLinkCommonData.swift
//  DoroDoro
//
//  Created by Jinwoo Kim on 2/25/21.
//

import Foundation

internal struct AddrLinkCommonData: Codable {
    /// 총 검색 데이터수
    internal let totalCount: String
    
    /// 페이지 번호
    internal let currentPage: String
    
    /// 페이지당 출력할 결과 Row 수
    internal let countPerPage: String
    
    /// 에러 코드
    internal let errorCode: String
    
    /// 에러 메시지
    internal let errorMessage: String
}
