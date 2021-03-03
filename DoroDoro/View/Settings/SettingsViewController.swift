//
//  SettingsViewController.swift
//  DoroDoro
//
//  Created by Jinwoo Kim on 2/25/21.
//

import UIKit

final internal class SettingsViewController: UIViewController {
    private weak var collectionView: UICollectionView? = nil
    private var viewModel: SettingsViewModel? = nil
    
    override internal func viewDidLoad() {
        super.viewDidLoad()
        setAttributes()
        configureCollectionView()
        configureViewModel()
    }
    
    private func setAttributes() {
        view.backgroundColor = .systemBackground
        title = "SETTINGS"
    }
    
    private func configureViewModel() {
        viewModel = .init()
        viewModel?.dataSource = makeDataSource()
    }
    
    private func configureCollectionView() {
        var layoutConfiguration: UICollectionLayoutListConfiguration = .init(appearance: .insetGrouped)
        layoutConfiguration.headerMode = .supplementary
        let layout: UICollectionViewCompositionalLayout = .list(using: layoutConfiguration)
        
        let collectionView: UICollectionView = .init(frame: .zero, collectionViewLayout: layout)
        self.collectionView = collectionView
        view.addSubview(collectionView)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.snp.remakeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        collectionView.backgroundColor = .systemBackground
        collectionView.delegate = self
    }
    
    private func makeDataSource() -> SettingsViewModel.DataSource {
        guard let collectionView: UICollectionView = collectionView else {
            return .init()
        }
        
        let dataSource: SettingsViewModel.DataSource = .init(collectionView: collectionView) { [weak self] (collectionView, indexPath, item) -> UICollectionViewCell? in
            guard let self = self else { return nil }
            return collectionView.dequeueConfiguredReusableCell(using: self.getCellRegisteration(), for: indexPath, item: item)
        }
        
        dataSource.supplementaryViewProvider = { [weak self] (collectionView, elementKind, indexPath) -> UICollectionReusableView? in
            guard let self = self else { return nil }
            
            if elementKind == UICollectionView.elementKindSectionHeader {
                return self.collectionView?.dequeueConfiguredReusableSupplementary(using: self.getHeaderCellRegisteration(), for: indexPath)
            }

            return nil
        }
        
        return dataSource
    }
    
    private func getCellRegisteration() -> UICollectionView.CellRegistration<UICollectionViewListCell, SettingCellItem> {
        return .init { [weak self] (cell, indexPath, item) in
            var configuration: UIListContentConfiguration = cell.defaultContentConfiguration()
            
            switch item.cellType {
            case .toggleCloud(let enabled):
                configuration.text = "CLOUD"
                configuration.image = UIImage(systemName: "icloud")
                
                let toggleAction: UIAction = .init { [weak self] action in
                    guard let toggleSwitch: UISwitch = action.sender as? UISwitch else {
                        return
                    }
                    self?.viewModel?.updateCloud(new: toggleSwitch.isOn)
                }
                
                let toggleSwitch: UISwitch = .init(frame: .zero,
                                                   primaryAction: toggleAction)
                toggleSwitch.isOn = enabled
                
                let accessoryConfiguration: UICellAccessory.CustomViewConfiguration = .init(customView: toggleSwitch,
                                                                               placement: .trailing(displayed: .always))
                cell.accessories = [.customView(configuration: accessoryConfiguration)]
            }
            
            cell.contentConfiguration = configuration
        }
    }
    
    private func getHeaderCellRegisteration() -> UICollectionView.SupplementaryRegistration<UICollectionViewListCell> {
        return .init(elementKind: UICollectionView.elementKindSectionHeader) { [weak self] (headerView, elementKind, indexPath) in
            guard let dataSource: SettingsViewModel.DataSource = self?.viewModel?.dataSource else { return }
            guard dataSource.snapshot().sectionIdentifiers.count > indexPath.section else { return }
            
            let headerItem: SettingHeaderItem = dataSource.snapshot().sectionIdentifiers[indexPath.section]
            
            var configuration: UIListContentConfiguration = headerView.defaultContentConfiguration()
            
            switch headerItem.headerType {
            case .cloud:
                configuration.text = "CLOUD(번역)"
            default:
                configuration.text = "DEMO"
            }
            headerView.contentConfiguration = configuration
        }
    }
}

extension SettingsViewController: UICollectionViewDelegate {
    
}
