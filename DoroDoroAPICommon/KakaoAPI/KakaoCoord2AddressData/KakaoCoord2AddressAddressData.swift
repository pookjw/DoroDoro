//
//  KakaoCoord2AddressAddressData.swift
//  DoroDoro
//
//  Created by Jinwoo Kim on 3/7/21.
//

import Foundation

public struct KakaoCoord2AddressAddressData: Decodable {
    /// 전체 지번 주소
    public let address_name: String
    
    /// 지역 1Depth명 - 시도 단위
    public let region_1depth_name: String
    
    /// 지역 2Depth명 - 구 단위
    public let region_2depth_name: String
    
    /// 지역 3Depth명 - 동 단위
    public let region_3depth_name: String
    
    /// 산 여부, Y 또는 N
    public let mountain_yn: String
    
    /// 지번 주 번지
    public let main_address_no: String
    
    /// 지번 부 번지, 없을 경우 ""
    public let sub_address_no: String
}
