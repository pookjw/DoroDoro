//
//  AddrLinkJusoData.swift
//  DoroDoro
//
//  Created by Jinwoo Kim on 2/25/21.
//

import Foundation

public struct AddrLinkJusoData: Decodable, Hashable {
    /// 전체 도로명주소
    public let roadAddr: String
    
    /// 도로명주소 (참고항목 제외)
    public let roadAddrPart1: String
    
    /// 도로명주소 참고항목
    public let roadAddrPart2: String?
    
    /// 지번주소
    public let jibunAddr: String
    
    /// 도로명주소(영문)
    public let engAddr: String
    
    /// 우편번호
    public let zipNo: String
    
    /// 행정구역코드
    public let admCd: String
    
    /// 도로명코드
    public let rnMgtSn: String
    
    /// 건물관리번호
    public let bdMgtSn: String
    
    /// 상세건물명
    public let detBdNmList: String?
    
    /// 건물명
    public let bdNm: String?
    
    /// 공동주택여부
    ///
    /// - `0`: 비공동주택
    /// - `1`: 공동주택
    public let bdKdcd: String?
    
    /// 시도명
    public let siNm: String
    
    /// 시군구명
    public let sggNm: String
    
    /// 읍면동명
    public let emdNm: String
    
    /// 법정리명
    public let liNm: String?
    
    /// 도로명
    public let rn: String
    
    /// 지하여부
    ///
    /// - `0` : 지상
    /// - `1` : 지하
    public let udrtYn: String
    
    /// 건물본번
    public let buldMnnm: String
    
    /// 건물부번
    public let buldSlno: String
    
    /// 산여부
    ///
    /// - `0` : 대지
    /// - `1` : 산
    public let mtYn: String
    
    /// 지번본번(번지)
    public let lnbrMnnm: String
    
    /// 지번부번(호)
    public let lnbrSlno: String
    
    /// 읍면동일련번호
    public let emdNo: String
    
    /// 변동이력여부
    ///
    /// - `0` : 현행 주소정보
    /// - `1` : 요청변수의 keyword(검색어)가 변동된 주소정보에서 검색된 정보
    public let hstryYn: String?
    
    /// 관련지번
    public let relJibun: String?
    
    /// 관할주민센터 (참고정보)
    ///
    /// 참고정보이며, 실제와 다를 수 있습니다
    public let hemdNm: String?
}

extension AddrLinkJusoData: Equatable {
    public static func == (lhs: AddrLinkJusoData, rhs: AddrLinkJusoData) -> Bool {
        return lhs.roadAddr == rhs.roadAddr
    }
}
