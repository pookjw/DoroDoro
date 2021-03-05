//
//  AddrLinkAPIError.swift
//  DoroDoro
//
//  Created by Jinwoo Kim on 2/26/21.
//

import Foundation

public enum AddrLinkAPIError: String, Error {
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
    
    /// 검색어가 입력되지 않았습니다.
    ///
    /// - 조치방법 : 검색어를 입력해주세요.
    case emptyKeyword = "E0005"
    
    /// 주소를 상세히 입력해 주시기 바랍니다.
    ///
    /// - 조치방법 : 시도명으로는 검색이 불가합니다.
    case deficientKeyword = "E0006"
    
    /// 검색어는 두글자 이상 입력되어야 합니다.
    ///
    /// - 조치방법 : 한 글자만으로는 검색이 불가합니다.
    case tooShortKeyword = "E0008"
    
    /// 검색어는 문자와 숫자 같이 입력되어야 합니다.
    ///
    /// - 조치방법 : 숫자만으로는 검색이 불가합니다.
    case wrongKeyword = "E0009"
    
    /// 검색어가 너무 깁니다. (한글40자, 영문,숫자 80자 이하)
    ///
    /// - 조치방법 : 80글자를 초과한 검색어는 검색이 불가합니다.
    case tooLongKeyword = "E0010"
    
    /// 검색어에 너무 긴 숫자가 포함되어 있습니다. (숫자10자 이하)
    ///
    /// - 조치방법 : 10자리를 초과하는 숫자가 포함된 검색어는 검색이 불가합니다.
    case tooLongIntegerKeyword = "E0011"
    
    /// 특수문자와 숫자만으로 이루어진 검색어는 검색이 불가합니다.
    ///
    /// - 조치방법 : 특수문자+숫자만으로는 검색이 불가능 합니다.
    case keywordOnlyContainsSpecialCharacter = "E0012"
    
    /// SQL 예약어 또는 특수문자( %,=,>,<,[,] )는 검색이 불가능 합니다.
    ///
    /// - 조치방법 : SQL예약어 또는 특수문자를 제거 후 검색합니다.
    case keywordContainsSQLReservedCharacter = "E0013"
    
    /// 개발승인키 기간이 만료되어 서비스를 이용하실 수 없습니다.
    ///
    /// - 조치방법 : 개발승인키를 다시 발급받아 API서비스를 호출합니다.
    case expiredApiKey = "E0014"
    
    /// 검색 범위를 초과하였습니다.
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

