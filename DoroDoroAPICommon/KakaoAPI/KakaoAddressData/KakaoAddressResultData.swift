//
//  KakaoAddressResultData.swift
//  DoroDoro
//
//  Created by Jinwoo Kim on 3/1/21.
//

import Foundation

public struct KakaoAddressResultData: Decodable {
    public let meta: KakaoAddressMetaData
    public let documents: [KakaoAddressDocumentData]
}
