//
//  KakaoAddressAPIError.swift
//  DoroDoro
//
//  Created by Jinwoo Kim on 3/1/21.
//

import Foundation

public enum KakaoAddressAPIError: String, Error {
    /// Response 에러
    case responseError
    
    /// JSON 파싱 에러
    case jsonError
    
    /// 결과 없을 경우 에러
    case noResults
    
    /// 알 수 없는 에러
    case unknownError
}
