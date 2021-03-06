//
//  KakaoCoord2AddressDocumentData.swift
//  DoroDoro
//
//  Created by Jinwoo Kim on 3/7/21.
//

import Foundation

public struct KakaoCoord2AddressDocumentData: Decodable {
    /// 지번 주소 상세 정보, 아래 address 항목 구성 요소 참고
    public let address: KakaoCoord2AddressAddressData
    
    /// 도로명 주소 상세 정보, 아래 RoadAddress 항목 구성 요소 참고
    public let road_address: KakaoCoord2AddressRoadAddressData
}
