//
//  KakaoAddressMetaData.swift
//  DoroDoro
//
//  Created by Jinwoo Kim on 3/1/21.
//

import Foundation

internal struct KakaoAddressMetaData: Decodable {
    /// 검색어에 검색된 문서 수
    internal let total_count: Int
    
    /// total_count 중 노출 가능 문서 수 (최대값: 45)
    internal let pageable_count: Int
    
    /// 현재 페이지가 마지막 페이지인지 여부
    ///
    /// 값이 false이면 page를 증가시켜 다음 페이지 요청 가능
    internal let is_end: Bool
}
