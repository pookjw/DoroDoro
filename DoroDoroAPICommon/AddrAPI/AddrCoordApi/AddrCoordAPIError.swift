//
//  AddrCoordAPIError.swift
//  DoroDoro
//
//  Created by Jinwoo Kim on 3/1/21.
//

import Foundation

public enum AddrCoordAPIError: String, Error {
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
    
    /// 행정구역코드(admCd)의 요청항목이 없습니다.
    ///
    /// - 조치방법 : 요청변수 중 행정구역코드(admCd)를 다시 확인하세요.
    case emptyAdmCd = "E0002"
    
    /// 도로명코드(rnMgtSn)의 요청항목이 없습니다.
    ///
    /// - 조치방법 : 요청변수 중 도로명코드(rnMgtSn)를 다시 확인하세요.
    case emptyRnMgtSn = "E0003"
    
    /// 지하여부(udrtYn)의 요청항목이 없습니다.
    ///
    /// - 조치방법 : 요청변수 중 지하여부(udrtYn)를 다시 확인하세요.
    case emptyUdrtYn = "E0004"
    
    /// 건물본번(buldMnnm)의 요청항목이 없습니다.
    ///
    /// - 조치방법 : 요청변수 중 건물본번(buldMnnm)을 다시 확인하세요.
    case emptyBuldMnnm = "E0005"
    
    /// 건물부번(buldSlno)의 요청항목이 없습니다.
    ///
    /// - 조치방법 : 요청변수 중 건물부번(buldSlno)을 다시 확인하세요.
    case emptyBuldSlno = "E0006"
    
    /// 짦은 시간동안 다량의 주소검색 요청이 있습니다. 잠시 후 이용하시길 바랍니다.
    ///
    /// - 조치방법 : 비정상적인 연속된 호출을 삼가하세요.
    case tooManyRequests = "E0007"
    
    /// Response 에러
    case responseError
    
    /// JSON 파싱 에러
    case jsonError
    
    /// 결과 없을 경우 에러
    case noResults
    
    /// 알 수 없는 에러
    case unknownError
}
