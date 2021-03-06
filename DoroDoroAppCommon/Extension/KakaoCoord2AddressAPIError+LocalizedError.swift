//
//  KakaoCoord2AddressAPIError+LocalizedError.swift
//  DoroDoro
//
//  Created by Jinwoo Kim on 3/7/21.
//

import Foundation
#if os(watchOS)
import DoroDoroWatchAPI
#else
import DoroDoroAPI
#endif

extension KakaoCoord2AddressAPIError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        default:
            return self.rawValue
        }
    }
}
