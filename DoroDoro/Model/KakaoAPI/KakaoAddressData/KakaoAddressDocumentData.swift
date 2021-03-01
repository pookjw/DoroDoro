//
//  KakaoAddressDocumentData.swift
//  DoroDoro
//
//  Created by Jinwoo Kim on 3/1/21.
//

import Foundation

internal struct KakaoAddressDocumentData: Decodable {
    /// 전체 지번 주소 또는 전체 도로명 주소, 입력에 따라 결정됨
    internal let address_name: String
    
    /// address_name의 값의 타입(Type)
    ///
    /// REGION(지명), ROAD(도로명), REGION_ADDR(지번 주소), ROAD_ADDR (도로명 주소) 중 하나
    internal let address_type: String
    
    /// X 좌표값, 경위도인 경우 longitude (경도)
    internal let x: String
    
    /// Y 좌표값, 경위도인 경우 latitude(위도)
    internal let y: String
    
    /// 지번 주소 상세 정보
    internal let address: KakaoAddressAddressData
    
    /// 도로명 주소 상세 정보
    ///
    /// null이 나올 때가 있다.
    internal let road_address: KakaoAddressRoadAddressData?
}
