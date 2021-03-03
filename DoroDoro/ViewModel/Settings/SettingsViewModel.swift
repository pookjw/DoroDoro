//
//  SettingsViewModel.swift
//  DoroDoro
//
//  Created by Jinwoo Kim on 3/4/21.
//

import Foundation
import UIKit
import Combine

final internal class SettingsViewModel {
    internal typealias DataSource = UICollectionViewDiffableDataSource<SettingHeaderItem, SettingCellItem>
    internal typealias Snapshot = NSDiffableDataSourceSnapshot<SettingHeaderItem, SettingCellItem>
    private var cancellableBag: Set<AnyCancellable> = .init()
    
    internal var dataSource: DataSource? = nil
    
    internal init() {
        bind()
    }
    
    internal func getCellItem(from indexPath: IndexPath) -> SettingCellItem? {
        guard let sectionIdentifiers: [SettingHeaderItem] = dataSource?.snapshot().sectionIdentifiers else {
            return nil
        }
        
        guard sectionIdentifiers.count > indexPath.section else {
            return nil
        }
        
        guard let cellItems: [SettingCellItem] = dataSource?.snapshot().itemIdentifiers(inSection: sectionIdentifiers[indexPath.section]) else {
            return nil
        }
        
        guard cellItems.count > indexPath.row else {
            return nil
        }
        
        return cellItems[indexPath.row]
    }
    
    internal func getSectionHeaderType(from indexPath: IndexPath) -> SettingHeaderItem.HeaderType? {
        guard let sectionIdentifiers: [SettingHeaderItem] = dataSource?.snapshot().sectionIdentifiers else {
            return nil
        }
        guard sectionIdentifiers.count > indexPath.section else {
            return nil
        }
        return sectionIdentifiers[indexPath.section].headerType
    }
    
    internal func updateMapSelection(new: MapSelection) {
        var data: SettingsData = SettingsService.shared.data
        data.mapSelection = new
        SettingsService.shared.save(data: data)
    }
    
    private func updateSettings(data: SettingsData) {
        updateMapSelectionItem(selected: data.mapSelection)
    }
    
    private func updateMapSelectionItem(selected: MapSelection) {
        guard var snapshot: Snapshot = dataSource?.snapshot() else {
            return
        }
        
        let mapHeaderItem: SettingHeaderItem = {
            if let mapHeaderItem: SettingHeaderItem = snapshot.sectionIdentifiers.first(where: { $0.headerType == .map }) {
                snapshot.deleteSections([mapHeaderItem])
                snapshot.appendSections([mapHeaderItem])
                return mapHeaderItem
            } else {
                let mapHeaderItem: SettingHeaderItem = .init(headerType: .map)
                snapshot.appendSections([mapHeaderItem])
                return mapHeaderItem
            }
        }()
        
        let items: [SettingCellItem] = [
            .init(cellType: .mapSelection(mapType: .appleMap, selected: selected == .appleMap)),
            .init(cellType: .mapSelection(mapType: .kakaoMap, selected: selected == .kakaoMap))
        ]

        snapshot.appendItems(items, toSection: mapHeaderItem)
        sortSnapshot(&snapshot)
        dataSource?.apply(snapshot, animatingDifferences: true)
    }
    
    private func sortSnapshot(_ snapshot: inout Snapshot)  {
        var sectionIdentifiers: [SettingHeaderItem] = snapshot.sectionIdentifiers
        
        for a in 0..<sectionIdentifiers.count {
            for b in (a + 1)..<sectionIdentifiers.count {
                if (sectionIdentifiers[a].headerType.rawValue) > (sectionIdentifiers[b].headerType.rawValue) {
                    
                    snapshot.moveSection(sectionIdentifiers[b], beforeSection: sectionIdentifiers[a])
                    for c in (a + 1)..<b {
                        snapshot.moveSection(sectionIdentifiers[c], afterSection: sectionIdentifiers[c + 1])
                    }
                        
                    sectionIdentifiers.swapAt(a, b)
                }
            }
        }
    }
    
    private func bind() {
        SettingsService.shared.dataEvent
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] data in
                self?.updateSettings(data: data)
            })
            .store(in: &cancellableBag)
    }
}