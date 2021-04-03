//
//  ShortcutService.swift
//  DoroDoro
//
//  Created by Jinwoo Kim on 4/2/21.
//

#if os(iOS)
import UIKit
#endif
import Foundation
import Combine

internal final class ShortcutService {
    internal enum ShortcutType: CustomStringConvertible {
        
        case search(text: String?), searchCurrentLocation, bookmarks
        
        internal var description: String {
            switch self {
            case .search(_):
                return "search"
            case .searchCurrentLocation:
                return "searchCurrentLocation"
            case .bookmarks:
                return "bookmarks"
            }
        }
    }
    
    internal static let shared: ShortcutService = .init()
    
    internal let typeEvent: PassthroughSubject<ShortcutType, Never> = .init()
    
    internal func handle(for url: URL) {
        guard let components: URLComponents = URLComponents(url: url, resolvingAgainstBaseURL: false),
              let queryItem: URLQueryItem = components.queryItems?.first else {
            return
        }
        
        switch queryItem.name {
        case ShortcutType.search(text: queryItem.value).description:
            typeEvent.send(.search(text: queryItem.value))
        case ShortcutType.searchCurrentLocation.description:
            typeEvent.send(.searchCurrentLocation)
        case ShortcutType.bookmarks.description:
            typeEvent.send(.bookmarks)
        default:
            break
        }
    }
    
    #if os(iOS)
    internal func handle(for shortcutItem: UIApplicationShortcutItem) {
        switch shortcutItem.type {
        case ShortcutType.search(text: nil).description:
            typeEvent.send(.search(text: nil))
        case ShortcutType.searchCurrentLocation.description:
            typeEvent.send(.searchCurrentLocation)
        case ShortcutType.bookmarks.description:
            typeEvent.send(.bookmarks)
        default:
            break
        }
    }
    
    internal static func getShortcutItems() -> [UIApplicationShortcutItem] {
        return [
            .init(type: ShortcutType.bookmarks.description,
                  localizedTitle: Localizable.BOOKMARKS.string,
                  localizedSubtitle: nil,
                  icon: .init(systemImageName: "bookmark"),
                  userInfo: nil),
            
            .init(type: ShortcutType.searchCurrentLocation.description,
                  localizedTitle: Localizable.CURRENT_LOCATION.string,
                  localizedSubtitle: nil,
                  icon: .init(systemImageName: "location"),
                  userInfo: nil),
            
            .init(type: ShortcutType.search(text: nil).description,
                  localizedTitle: Localizable.SEARCH.string,
                  localizedSubtitle: nil,
                  icon: .init(systemImageName: "magnifyingglass"),
                  userInfo: nil)
        ]
    }
    #endif
}