//
//  KakaoCoord2AddressMetaData.swift
//  DoroDoro
//
//  Created by Jinwoo Kim on 3/7/21.
//

import Foundation

public struct KakaoCoord2AddressMetaData: Decodable {
    /// 변환된 지번 주소 및 도로명 주소 의 개수, 0 또는 1
    public let total_count: Int
}
