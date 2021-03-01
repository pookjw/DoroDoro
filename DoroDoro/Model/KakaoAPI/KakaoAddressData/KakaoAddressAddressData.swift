//
//  KakaoAddressAddressData.swift
//  DoroDoro
//
//  Created by Jinwoo Kim on 3/1/21.
//

import Foundation

internal struct KakaoAddressAddressData: Decodable {
    /// 전체 지번 주소
    internal let address_name: String
    
    /// 지역 1 Depth, 시도 단위
    internal let region_1depth_name: String
    
    /// 지역 2 Depth, 구 단위
    internal let region_2depth_name: String
    
    /// 지역 3 Depth, 동 단위
    internal let region_3depth_name: String
    
    /// 지역 3 Depth, 행정동 명칭
    internal let region_3depth_h_name: String
    
    /// 행정 코드
    internal let h_code: String
    
    /// 법정 코드
    internal let b_code: String
    
    /// 산 여부, Y 또는 N
    internal let mountain_yn: String
    
    /// 지번 주번지
    internal let main_address_no: String
    
    /// 지번 부번지. 없을 경우 ""
    internal let sub_address_no: String
    
    /// X 좌표값, 경위도인 경우 longitude (경도)
    internal let x: String
    
    /// Y 좌표값, 경위도인 경우 latitude(위도)
    internal let y: String
}
