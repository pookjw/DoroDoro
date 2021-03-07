//
//  Localizable.swift
//  DoroDoro
//
//  Created by Jinwoo Kim on 2/26/21.
//

import Foundation

internal enum Localizable: String {
    case DORODORO
    case SEARCH
    case BOOKMARKS
    case SETTINGS
    case DETAILS
    case LOCATION
    case MAP_VIEW_CONTROLLER_TITLE
    case DONE
    case DISMISS
    case SEARCH_GUIDE_LABEL
    case SEARCH_GUIDE_WATCH
    case SEARCH_BAR_PLACEHOLDER_WATCH
    case BOOKMARK_GUIDE_LABEL
    case NO_DATA
    case RESULTS_FOR_ADDRESS
    case ADD_TO_BOOKMARKS
    case REMOVE_FROM_BOOKMARKS
    case OPEN_IN_KAKAOMAP_APP
    case OPEN_IN_APPLE_MAPS_APP
    case MAP_PROVIDERS
    case APPLE_MAPS
    case KAKAO_MAP
    case MAP_PROVIDERS_DESCRIPTION
    case DATA_PROVIDER_DESCRIPTION
    case POOKJW_NAME
    case POOKJW_ROLE
    case APP_INFO
    case CONTRIBUTORS
    case OPEN_SOURCE_ACKNOWLEDGEMENTS
    case COCOAPODS
    case ADDR_LINK
    case ADDR_ENG
    case MAP
    case COPY
    case SHARE
    case EMAIL_ERROR_NO_REGISTERED_EMAILS_ON_DEVICE
    case EMAIL_TITLE
    case EMAIL_APP_INFO
    case EMAIL_SYSTEM_INFO
    case EMAIL_SENT
    case SUCCESS
    case ERROR
    case ERROR_CONTACT_TO_DEVELOPER
    case UNKNOWN
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
    case KAKAO_ADDRESS_API_ERROR_RESPONSE
    case KAKAO_ADDRESS_API_ERROR_JSON_PARSE
    case KAKAO_ADDRESS_API_ERROR_NO_RESULTS
    case KAKAO_ADDRESS_API_UNKNOWN
    case KAKAO_COORD_TO_ADDRESS_API_ERROR_RESPONSE
    case KAKAO_COORD_TO_ADDRESS_API_ERROR_JSON_PARSE
    case KAKAO_COORD_TO_ADDRESS_API_ERROR_NO_RESULTS
    case KAKAO_COORD_TO_ADDRESS_API_UNKNOWN
    case ACCESSIBILITY_SEARCH_TEXTFIELD
    case ACCESSIBILITY_SEARCH_GUIDE
    case ACCESSIBILITY_SEARCH_CURRENT_LOCATION
    case ACCESSIBILITY_DETAILS_MAP
    case ACCESSIBILITY_MAP_OPEN_IN_APP
    case ACCESSIBILITY_MAP_GUIDE
    case ACCESSIBILITY_BOOKMARKS_GUIDE
    case ACCESSIBILITY_BOOKMARKS_TEXTFIELD
    case ACCESSIBILITY_REMOVE_FROM_BOOKMARK
    case ACCESSIBILITY_ADD_TO_BOOKMARK
    case ACCESSIBILITY_LOADING_CONENTS
    
    internal var string: String {
        NSLocalizedString(self.rawValue, comment: "")
    }
}
