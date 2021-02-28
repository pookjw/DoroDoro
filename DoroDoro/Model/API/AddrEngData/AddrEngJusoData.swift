//
//  AddrEngJusoData.swift
//  DoroDoro
//
//  Created by Jinwoo Kim on 2/26/21.
//

import Foundation

internal struct AddrEngJusoData: Codable {
    /// 영문 도로명주소
    internal let roadAddr: String
    
    /// 영문 지번주소
    internal let jibunAddr: String
    
    /// 우편번호
    internal let zipNo: String
    
    /// 행정구역코드
    internal let admCd: String

    /// 도로명코드
    internal let rnMgtSn: String
    
    /// 공동주택여부
    ///
    /// - `0`: 비공동주택
    /// - `1`: 공동주택
    internal let bdKdcd: String?
    
    /// 영문 시도명
    internal let siNm: String
    
    /// 영문 시군구명
    internal let sggNm: String
    
    /// 영문 읍면동명
    internal let emdNm: String
    
    /// 영문 법정리명
    internal let liNm: String?
    
    /// 영문 도로명
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
    
    /// 도로명주소(한글)
    internal let korAddr: String
}
