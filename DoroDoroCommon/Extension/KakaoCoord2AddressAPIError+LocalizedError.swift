//
//  KakaoCoord2AddressAPIError+LocalizedError.swift
//  DoroDoro
//
//  Created by Jinwoo Kim on 3/7/21.
//

import Foundation
#if os(watchOS)
import DoroDoroWatchAPI
#elseif os(tvOS)
import DoroDoroTVAPI
#elseif os(macOS)
import DoroDoroMacAPI
#else
import DoroDoroAPI
#endif

extension KakaoCoord2AddressAPIError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .responseError:
            return Localizable.KAKAO_COORD_TO_ADDRESS_API_ERROR_RESPONSE.string
        case .jsonError:
            return Localizable.KAKAO_COORD_TO_ADDRESS_API_ERROR_JSON_PARSE.string
        case .noResults:
            return Localizable.KAKAO_COORD_TO_ADDRESS_API_ERROR_NO_RESULTS.string
        case .unknownError:
            return Localizable.KAKAO_COORD_TO_ADDRESS_API_UNKNOWN.string
        default:
            return self.rawValue
        }
    }
}
