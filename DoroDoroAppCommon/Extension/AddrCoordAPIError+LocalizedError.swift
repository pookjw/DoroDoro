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

extension AddrCoordAPIError: LocalizedError {
    public var errorDescription: String? {
        return self.rawValue
    }
}
