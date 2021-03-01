//
//  AddrEngAPIError.swift
//  DoroDoro
//
//  Created by Jinwoo Kim on 2/26/21.
//

import Foundation

internal enum AddrEngAPIError: String, Error {
    /// 정상
    case normal = "0"
    
    /// 시스템에러
    ///
    /// - 조치방법 : 도로명주소 도움센터로 문의하시기 바랍니다.
    case systemError = "-999"
    
    /// 승인되지 않은 KEY 입니다.
    ///
    /// - 조치방법 : 정확한 승인키를 입력하세요.(팝업API 승인키 사용불가)
    case unauthorizedApiKey = "E0001"
    
    /// No search word has been entered.
    ///
    /// - 조치방법 : 검색어를 입력해주세요.
    case emptyKeyword = "E0005"
    
    /// Please enter your address in detail.
    ///
    /// - 조치방법 : 시도명으로는 검색이 불가합니다.
    case deficientKeyword = "E0006"
    
    /// Address entered too short.
    ///
    /// - 조치방법 : 한 글자만으로는 검색이 불가합니다.
    case tooShortKeyword = "E0008"
    
    /// It is not possible to search by address only number.
    ///
    /// - 조치방법 : 숫자만으로는 검색이 불가합니다.
    case wrongKeyword = "E0009"
    
    /// Address entered too long.
    ///
    /// - 조치방법 : 80글자를 초과한 검색어는 검색이 불가합니다.
    case tooLongKeyword = "E0010"
    
    /// Long numbers are included.
    ///
    /// - 조치방법 : 10자리를 초과하는 숫자가 포함된 검색어는 검색이 불가합니다.
    case tooLongIntegerKeyword = "E0011"
    
    /// Can not search special characters + numbers.
    ///
    /// - 조치방법 : 특수문자+숫자만으로는 검색이 불가능 합니다.
    case keywordOnlyContainsSpecialCharacter = "E0012"
    
    /// Can not search SQL & special characters(%,=,>,<,[,]).
    ///
    /// - 조치방법 : SQL예약어 또는 특수문자를 제거 후 검색합니다.
    case keywordContainsSQLReservedCharacter = "E0013"
    
    /// The authorization key preiod has expired.
    ///
    /// - 조치방법 : 개발승인키를 다시 발급받아 API서비스를 호출합니다.
    case expiredApiKey = "E0014"
    
    /// The search range has been exceeded.
    ///
    /// - 조치방법 : 검색결과가 9천건이 초과하는 검색은 불가합니다.
    case tooManyResults = "E0015"
    
    /// Response 에러
    case responseError
    
    /// JSON 파싱 에러
    case jsonError
    
    /// 결과 없을 경우 에러
    case noResults
    
    /// 알 수 없는 에러
    case unknownError
}

extension AddrEngAPIError: LocalizedError {
    internal var errorDescription: String? {
        switch self {
        case .normal:
            return Localizable.ADDR_ENG_API_ERROR_NORMAL.string
        case .systemError:
            return Localizable.ADDR_ENG_API_ERROR_SYSTEM_ERROR.string
        case .unauthorizedApiKey:
            return Localizable.ADDR_ENG_API_ERROR_UNAUTHORIZED_API_KEY.string
        case .emptyKeyword:
            return Localizable.ADDR_ENG_API_ERROR_EMPTY_KEYWORD.string
        case .deficientKeyword:
            return Localizable.ADDR_ENG_API_ERROR_DEFICIENT_KEYWORD.string
        case .tooShortKeyword:
            return Localizable.ADDR_ENG_API_ERROR_TOO_SHORT_KEYWORD.string
        case .wrongKeyword:
            return Localizable.ADDR_ENG_API_ERROR_WRONG_KEYWORD.string
        case .tooLongKeyword:
            return Localizable.ADDR_ENG_API_ERROR_TOO_LONG_KEYWORD.string
        case .tooLongIntegerKeyword:
            return Localizable.ADDR_ENG_API_ERROR_TOO_LONG_INTEGER_KEYWORD.string
        case .keywordOnlyContainsSpecialCharacter:
            return Localizable.ADDR_ENG_API_ERROR_KEYWORD_ONLY_CONTAINS_SPECIAL_CHARACTER.string
        case .keywordContainsSQLReservedCharacter:
            return Localizable.ADDR_ENG_API_ERROR_KEYWORD_COTAINS_SQL_RESERVED_CHARACTER.string
        case .expiredApiKey:
            return Localizable.ADDR_ENG_API_ERROR_EXPIRED_KEY.string
        case .tooManyResults:
            return Localizable.ADDR_ENG_API_ERROR_TOO_MANY_RESULTS.string
        case .responseError:
            return Localizable.ADDR_ENG_API_ERROR_RESPONSE.string
        case .jsonError:
            return Localizable.ADDR_ENG_API_ERROR_JSON_PARSE.string
        case .noResults:
            return Localizable.ADDR_ENG_API_ERROR_NO_RESULTS.string
        case .unknownError:
            return Localizable.ADDR_ENG_API_ERROR_UNKNOWN.string
        default:
            return self.rawValue
        }
    }
}