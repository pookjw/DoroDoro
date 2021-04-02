//
//  ShortcutService.swift
//  DoroDoro
//
//  Created by Jinwoo Kim on 4/2/21.
//

import UIKit
import Combine

internal final class ShortcutService {
    internal enum ShortcutType: CustomStringConvertible {
        
        case search(text: String?), searchCurrentLocation, bookmark(text: String?)
        
        internal var description: String {
            switch self {
            case .search(_):
                return "search"
            case .searchCurrentLocation:
                return "searchCurrentLocation"
            case .bookmark(_):
                return "bookmark"
            }
        }
    }
    
    internal static let shared: ShortcutService = .init()
    
    internal let typeEvent: PassthroughSubject<ShortcutType, Never> = .init()
    
    internal func handle(for shortcutItem: UIApplicationShortcutItem) {
        switch shortcutItem.type {
        case ShortcutType.search(text: nil).description:
            typeEvent.send(.search(text: nil))
        case ShortcutType.searchCurrentLocation.description:
            typeEvent.send(.searchCurrentLocation)
        case ShortcutType.bookmark(text: nil).description:
            typeEvent.send(.bookmark(text: nil))
        default:
            break
        }
    }
    
    internal func handle(for url: URL) {
        
    }
    
    internal static func getShortcutItems() -> [UIApplicationShortcutItem] {
        return [
            .init(type: ShortcutType.bookmark(text: nil).description,
                  localizedTitle: "책갈피(번역)",
                  localizedSubtitle: nil,
                  icon: .init(systemImageName: "bookmark"),
                  userInfo: nil),
            
            .init(type: ShortcutType.searchCurrentLocation.description,
                  localizedTitle: "현재 위치 검색(번역)",
                  localizedSubtitle: nil,
                  icon: .init(systemImageName: "location"),
                  userInfo: nil),
            
            .init(type: ShortcutType.search(text: nil).description,
                  localizedTitle: "검색(번역)",
                  localizedSubtitle: nil,
                  icon: .init(systemImageName: "magnifyingglass"),
                  userInfo: nil)
        ]
    }
}
