//
//  Localizable.swift
//  DoroDoro
//
//  Created by Jinwoo Kim on 2/26/21.
//

import Foundation

public enum Localizable: String {
    case DORODORO
    case TABBAR_SEARCH_VIEW_CONTROLLER_TITLE
    case TABBAR_BOOKMARK_VIEW_CONTROLLER_TITLE
    case TABBAR_SETTINGS_VIEW_CONTROLLER_TITLE
    case ERROR_CONTACT_TO_DEVELOPER
    case ADDR_LINK_API_ERROR_NORMAL
    case ADDR_LINK_API_ERROR_SYSTEM_ERROR
    case ADDR_LINK_API_ERROR_UNAUTHORIZED_API_KEY
    case ADDR_LINK_API_ERROR_EMPTY_KEYWORD
    case ADDR_LINK_API_ERROR_DEFICIENT_KEYWORD
    case ADDR_LINK_API_ERROR_TOO_SHORT_KEYWORD
    case ADDR_LINK_API_ERROR_WRONG_KEYWORD
    case ADDR_LINK_API_ERROR_TOO_LONG_KEYWORD
    case ADDR_LINK_API_ERROR_TOO_LONG_INTEGER_KEYWORD
    case ADDR_LINK_API_ERROR_KEYWORD_ONLY_CONTAINS_SPECIAL_CHARACTER
    case ADDR_LINK_API_ERROR_KEYWORD_COTAINS_SQL_RESERVED_CHARACTER
    case ADDR_LINK_API_ERROR_EXPIRED_KEY
    case ADDR_LINK_API_ERROR_TOO_MANY_RESULTS
    case ADDR_LINK_API_ERROR_RESPONSE
    case ADDR_LINK_API_ERROR_JSON_PARSE
    case ADDR_LINK_API_ERROR_NO_RESULTS
    case ADDR_LINK_API_ERROR_UNKNOWN
    case ADDR_ENG_API_ERROR_NORMAL
    case ADDR_ENG_API_ERROR_SYSTEM_ERROR
    case ADDR_ENG_API_ERROR_UNAUTHORIZED_API_KEY
    case ADDR_ENG_API_ERROR_EMPTY_KEYWORD
    case ADDR_ENG_API_ERROR_DEFICIENT_KEYWORD
    case ADDR_ENG_API_ERROR_TOO_SHORT_KEYWORD
    case ADDR_ENG_API_ERROR_WRONG_KEYWORD
    case ADDR_ENG_API_ERROR_TOO_LONG_KEYWORD
    case ADDR_ENG_API_ERROR_TOO_LONG_INTEGER_KEYWORD
    case ADDR_ENG_API_ERROR_KEYWORD_ONLY_CONTAINS_SPECIAL_CHARACTER
    case ADDR_ENG_API_ERROR_KEYWORD_COTAINS_SQL_RESERVED_CHARACTER
    case ADDR_ENG_API_ERROR_EXPIRED_KEY
    case ADDR_ENG_API_ERROR_TOO_MANY_RESULTS
    case ADDR_ENG_API_ERROR_RESPONSE
    case ADDR_ENG_API_ERROR_JSON_PARSE
    case ADDR_ENG_API_ERROR_NO_RESULTS
    case ADDR_ENG_API_ERROR_UNKNOWN
    
    public var string: String {
        NSLocalizedString(self.rawValue, comment: "")
    }
}
