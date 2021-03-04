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
    
    override internal func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationItem.largeTitleDisplayMode = .always
        navigationController?.navigationBar.prefersLargeTitles = true
        
        if let collectionView: UICollectionView = collectionView {
            animateForSelectedIndexPath(collectionView, animated: animated)
        }
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
        layoutConfiguration.footerMode = .supplementary
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
            } else if elementKind == UICollectionView.elementKindSectionFooter {
                return self.collectionView?.dequeueConfiguredReusableSupplementary(using: self.getFooterCellRegisteration(), for: indexPath)
            }

            return nil
        }
        
        return dataSource
    }
    
    private func getCellRegisteration() -> UICollectionView.CellRegistration<UICollectionViewListCell, SettingCellItem> {
        return .init { [weak self] (cell, indexPath, item) in
            switch item.cellType {
            case .mapSelection(let mapType, let selected):
                self?.setMapSelectionCell(cell: cell, mapType: mapType, selected: selected)
            case .contributor(let contributorType):
                self?.setContributorTypeCell(cell: cell, contributorType: contributorType)
            }
        }
    }
    
    private func getHeaderCellRegisteration() -> UICollectionView.SupplementaryRegistration<UICollectionViewListCell> {
        return .init(elementKind: UICollectionView.elementKindSectionHeader) { [weak self] (headerView, elementKind, indexPath) in
            guard let dataSource: SettingsViewModel.DataSource = self?.viewModel?.dataSource else { return }
            guard dataSource.snapshot().sectionIdentifiers.count > indexPath.section else { return }
            
            guard let headerItem: SettingHeaderItem = self?.viewModel?.getSectionHeaderItem(from: indexPath) else {
                return
            }
            
            var configuration: UIListContentConfiguration = headerView.defaultContentConfiguration()
            
            switch headerItem.headerType {
            case .map:
                configuration.text = "MAPS(번역)"
            case .contributor:
                configuration.text = "Contributors(번역)"
            }
            headerView.contentConfiguration = configuration
        }
    }
    
    private func getFooterCellRegisteration() -> UICollectionView.SupplementaryRegistration<UICollectionViewListCell> {
        return .init(elementKind: UICollectionView.elementKindSectionFooter) { [weak self] (footerView, elementKind, indexPath) in
            guard let dataSource: SettingsViewModel.DataSource = self?.viewModel?.dataSource else {
                return
            }
            guard dataSource.snapshot().sectionIdentifiers.count > indexPath.section else { return }
            
            guard let headerItem: SettingHeaderItem = self?.viewModel?.getSectionHeaderItem(from: indexPath) else {
                return
            }
            
            switch headerItem.headerType {
            case .map:
                var configuration: UIListContentConfiguration = footerView.defaultContentConfiguration()
                
                configuration.text = "상세 보기 화면과 Intel CPU에서는 카카오지도를 지원하지 않습니다.(번역)"
                configuration.textProperties.alignment = .center
                footerView.contentConfiguration = configuration
            default:
                footerView.contentConfiguration = nil
            }
        }
    }
    
    private func setMapSelectionCell(
        cell: UICollectionViewListCell,
        mapType: SettingsMapSelectionType,
        selected: Bool)
    {
        var configuration: UIListContentConfiguration = cell.defaultContentConfiguration()
        
        switch mapType {
        case .appleMap:
            configuration.text = "APPLE MAPS(번역)"
        case .kakaoMap:
            configuration.text = "KAKAO MAPS(번역)"
        }
        
        if selected {
            cell.accessories = [.checkmark()]
        } else {
            cell.accessories = []
        }
        
        cell.contentConfiguration = configuration
    }
    
    private func setContributorTypeCell(cell: UICollectionViewListCell, contributorType: SettingsContributorType) {
        var configuration: UIListContentConfiguration = cell.defaultContentConfiguration()
        
        switch contributorType {
        case .pookjw:
            configuration.image = UIImage(named: "pookjw")
            configuration.imageProperties.cornerRadius = 25
            configuration.imageProperties.maximumSize = .init(width: 50, height: 50)
            configuration.text = "김진우(번역필요)"
            configuration.secondaryText = "메인 개발자(번역필요)"
        }
        
        cell.contentConfiguration = configuration
        cell.accessories = [.disclosureIndicator()]
    }
}

extension SettingsViewController: UICollectionViewDelegate {
    internal func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let cellItem: SettingCellItem = viewModel?.getCellItem(from: indexPath) else {
             return
        }
        
        switch cellItem.cellType {
        case .mapSelection(let mapType, _):
            viewModel?.updateMapSelection(new: mapType)
            collectionView.deselectItem(at: indexPath, animated: true)
        case .contributor(let contributorType):
            switch contributorType {
            case .pookjw:
                if let url: URL = .init(string: "https://github.com/pookjw") {
                    presentSFSafariViewController(url)
                }
            }
        }
    }
}
