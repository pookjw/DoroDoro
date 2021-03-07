//
//  AddrCoordAPIError+LocalizedError.swift
//  DoroDoro
//
//  Created by Jinwoo Kim on 3/6/21.
//

import Foundation
#if os(watchOS)
import DoroDoroWatchAPI
#else
import DoroDoroAPI
#endif

/* 안 쓰는 API이므로 번역을 안했다. */

extension AddrCoordAPIError: LocalizedError {
    public var errorDescription: String? {
        return self.rawValue
    }
}
