//
//  KakaoCoord2AddressResultData.swift
//  DoroDoro
//
//  Created by Jinwoo Kim on 3/7/21.
//

import Foundation

public struct KakaoCoord2AddressResultData: Decodable {
    public let meta: KakaoCoord2AddressMetaData
    public let documents: [KakaoCoord2AddressDocumentData]
}
