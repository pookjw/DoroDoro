//
//  KakaoAddressResultData.swift
//  DoroDoro
//
//  Created by Jinwoo Kim on 3/1/21.
//

import Foundation

internal struct KakaoAddressResultData: Decodable {
    internal let meta: KakaoAddressMetaData
    internal let documents: [KakaoAddressDocumentData]
}
