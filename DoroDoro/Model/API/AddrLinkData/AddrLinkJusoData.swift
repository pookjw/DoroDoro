//
//  AddrLinkJusoData.swift
//  DoroDoro
//
//  Created by Jinwoo Kim on 2/25/21.
//

import Foundation

internal struct AddrLinkJusoData: Decodable {
    /// 전체 도로명주소
    internal let roadAddr: String
    
    /// 도로명주소 (참고항목 제외)
    internal let roadAddrPart1: String
    
    /// 도로명주소 참고항목
    internal let roadAddrPart2: String?
    
    /// 지번주소
    internal let jibunAddr: String
    
    /// 도로명주소(영문)
    internal let engAddr: String
    
    /// 우편번호
    internal let zipNo: String
    
    /// 행정구역코드
    internal let admCd: String
    
    /// 도로명코드
    internal let rnMgtSn: String
    
    /// 건물관리번호
    internal let bdMgtSn: String
    
    /// 상세건물명
    internal let detBdNmList: String?
    
    /// 건물명
    internal let bdNm: String?
    
    /// 공동주택여부
    ///
    /// - `0`: 비공동주택
    /// - `1`: 공동주택
    internal let bdKdcd: String?
    
    /// 시도명
    internal let siNm: String
    
    /// 시군구명
    internal let sggNm: String
    
    /// 읍면동명
    internal let emdNm: String
    
    /// 법정리명
    internal let liNm: String?
    
    /// 도로명
    internal let rn: String
    
    /// 지하여부
    ///
    /// - `0` : 지상
    /// - `1` : 지하
    internal let udrtYn: String
    
    /// 건물본번
    internal let buldMnnm: String
    
    /// 건물부번
    internal let buldSlno: String
    
    /// 산여부
    ///
    /// - `0` : 대지
    /// - `1` : 산
    internal let mtYn: String
    
    /// 지번본번(번지)
    internal let lnbrMnnm: String
    
    /// 지번부번(호)
    internal let lnbrSlno: String
    
    /// 읍면동일련번호
    internal let emdNo: String
    
    /// 변동이력여부
    ///
    /// - `0` : 현행 주소정보
    /// - `1` : 요청변수의 keyword(검색어)가 변동된 주소정보에서 검색된 정보
    internal let hstryYn: String?
    
    /// 관련지번
    internal let relJibun: String?
    
    /// 관할주민센터 (참고정보)
    ///
    /// 참고정보이며, 실제와 다를 수 있습니다
    internal let hemdNm: String?
}

extension AddrLinkJusoData: Equatable {
    static internal func == (lhs: AddrLinkJusoData, rhs: AddrLinkJusoData) -> Bool {
        return lhs.roadAddr == rhs.roadAddr
    }
}

extension AddrLinkJusoData {
    internal func convertToAddrCoordSearchData() -> AddrCoordSearchData {
        return .init(admCd: admCd,
                     rnMgtSn: rnMgtSn,
                     udrtYn: udrtYn,
                     buldMnnm: buldMnnm,
                     buldSlno: buldSlno)
    }
}
