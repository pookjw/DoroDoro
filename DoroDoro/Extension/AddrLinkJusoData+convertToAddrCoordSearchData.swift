//
//  AddrLinkJusoData+convertToAddrCoordSearchData.swift
//  DoroDoro
//
//  Created by Jinwoo Kim on 3/6/21.
//

import Foundation
import DoroDoroAPI

extension AddrLinkJusoData {
    public func convertToAddrCoordSearchData() -> AddrCoordSearchData {
        return .init(admCd: admCd,
                     rnMgtSn: rnMgtSn,
                     udrtYn: udrtYn,
                     buldMnnm: buldMnnm,
                     buldSlno: buldSlno)
    }
}
