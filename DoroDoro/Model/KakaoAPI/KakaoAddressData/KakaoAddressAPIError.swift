//
//  KakaoAddressAPIError.swift
//  DoroDoro
//
//  Created by Jinwoo Kim on 3/1/21.
//

import Foundation

internal enum KakaoAddressAPIError: String, Error {
    /// Response 에러
    case responseError
    
    /// JSON 파싱 에러
    case jsonError
    
    /// 결과 없을 경우 에러
    case noResults
    
    /// 알 수 없는 에러
    case unknownError
}

extension KakaoAddressAPIError: LocalizedError {
    internal var errorDescription: String? {
        switch self {
        case .responseError:
            return Localizable.KAKAO_ADDRESS_API_ERROR_RESPONSE.string
        case .jsonError:
            return Localizable.KAKAO_ADDRESS_API_ERROR_JSON_PARSE.string
        case .noResults:
            return Localizable.KAKAO_ADDRESS_API_ERROR_NO_RESULTS.string
        case .unknownError:
            return Localizable.KAKAO_ADDRESS_API_UNKNOWN.string
        default:
            return self.rawValue
        }
    }
}
