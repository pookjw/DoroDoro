//
//  AddrEngJusoData.swift
//  DoroDoro
//
//  Created by Jinwoo Kim on 2/26/21.
//

import Foundation

public struct AddrEngJusoData: Decodable {
    /// 영문 도로명주소
    public let roadAddr: String
    
    /// 영문 지번주소
    public let jibunAddr: String
    
    /// 우편번호
    public let zipNo: String
    
    /// 행정구역코드
    public let admCd: String

    /// 도로명코드
    public let rnMgtSn: String
    
    /// 공동주택여부
    ///
    /// - `0`: 비공동주택
    /// - `1`: 공동주택
    public let bdKdcd: String?
    
    /// 영문 시도명
    public let siNm: String
    
    /// 영문 시군구명
    public let sggNm: String
    
    /// 영문 읍면동명
    public let emdNm: String
    
    /// 영문 법정리명
    public let liNm: String?
    
    /// 영문 도로명
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
    
    /// 도로명주소(한글)
    public let korAddr: String
}
