//
//  KakaoAddressRoadAddressData.swift
//  DoroDoro
//
//  Created by Jinwoo Kim on 3/1/21.
//

import Foundation

public struct KakaoAddressRoadAddressData: Decodable {
    /// 전체 도로명 주소
    public let address_name: String?

    /// 지역명1
    public let region_1depth_name: String

    /// 지역명2
    public let region_2depth_name: String

    /// 지역명3
    public let region_3depth_name: String

    /// 도로명
    public let road_name: String

    /// 지하 여부, Y 또는 N
    public let underground_yn: String

    /// 건물 본번
    public let main_building_no: String

    /// 건물 부번. 없을 경우 ""
    public let sub_building_no: String

    /// 건물 이름
    public let building_name: String

    /// 우편번호(5자리)
    public let zone_no: String

    /// X 좌표값, 경위도인 경우 longitude (경도)
    public let x: String

    /// Y 좌표값, 경위도인 경우 latitude(위도)
    public let y: String
}
