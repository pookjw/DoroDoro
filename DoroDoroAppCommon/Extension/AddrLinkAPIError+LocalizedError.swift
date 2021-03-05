//
//  AddrLinkAPIError+LocalizedError.swift
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

extension AddrLinkAPIError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .normal:
            return Localizable.ADDR_LINK_API_ERROR_NORMAL.string
        case .systemError:
            return Localizable.ADDR_LINK_API_ERROR_SYSTEM_ERROR.string
        case .unauthorizedApiKey:
            return Localizable.ADDR_LINK_API_ERROR_UNAUTHORIZED_API_KEY.string
        case .emptyKeyword:
            return Localizable.ADDR_LINK_API_ERROR_EMPTY_KEYWORD.string
        case .deficientKeyword:
            return Localizable.ADDR_LINK_API_ERROR_DEFICIENT_KEYWORD.string
        case .tooShortKeyword:
            return Localizable.ADDR_LINK_API_ERROR_TOO_SHORT_KEYWORD.string
        case .wrongKeyword:
            return Localizable.ADDR_LINK_API_ERROR_WRONG_KEYWORD.string
        case .tooLongKeyword:
            return Localizable.ADDR_LINK_API_ERROR_TOO_LONG_KEYWORD.string
        case .tooLongIntegerKeyword:
            return Localizable.ADDR_LINK_API_ERROR_TOO_LONG_INTEGER_KEYWORD.string
        case .keywordOnlyContainsSpecialCharacter:
            return Localizable.ADDR_LINK_API_ERROR_KEYWORD_ONLY_CONTAINS_SPECIAL_CHARACTER.string
        case .keywordContainsSQLReservedCharacter:
            return Localizable.ADDR_LINK_API_ERROR_KEYWORD_COTAINS_SQL_RESERVED_CHARACTER.string
        case .expiredApiKey:
            return Localizable.ADDR_LINK_API_ERROR_EXPIRED_KEY.string
        case .tooManyResults:
            return Localizable.ADDR_LINK_API_ERROR_TOO_MANY_RESULTS.string
        case .responseError:
            return Localizable.ADDR_LINK_API_ERROR_RESPONSE.string
        case .noResults:
            return Localizable.ADDR_LINK_API_ERROR_NO_RESULTS.string
        case .jsonError:
            return Localizable.ADDR_LINK_API_ERROR_JSON_PARSE.string
        case .unknownError:
            return Localizable.ADDR_LINK_API_ERROR_UNKNOWN.string
        default:
            return self.rawValue
        }
    }
}
