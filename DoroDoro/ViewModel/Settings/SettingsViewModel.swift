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
    
    internal func updateCloud(new: Bool) {
        var data: SettingsData = SettingsService.shared.data
        data.enabledCloudService = new
        SettingsService.shared.save(data: data)
    }
    
    private func updateCloudItems(data: SettingsData) {
        guard var snapshot: Snapshot = dataSource?.snapshot() else {
            return
        }
        
        let cloudHeaderItem: SettingHeaderItem = {
            if let cloudHeaderItem: SettingHeaderItem = snapshot.sectionIdentifiers.first(where: { $0.headerType == .cloud }) {
                snapshot.deleteSections([cloudHeaderItem])
                snapshot.appendSections([cloudHeaderItem])
                return cloudHeaderItem
            } else {
                let cloudHeaderItem: SettingHeaderItem = .init(headerType: .cloud)
                snapshot.appendSections([cloudHeaderItem])
                return cloudHeaderItem
            }
        }()
        
        let items: [SettingCellItem] = [
            .init(cellType: .toggleCloud(enabled: data.enabledCloudService))
        ]
        
        snapshot.appendItems(items, toSection: cloudHeaderItem)
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
                self?.updateCloudItems(data: data)
            })
            .store(in: &cancellableBag)
    }
}
