//
//  DetailsViewController.swift
//  DoroDoro
//
//  Created by Jinwoo Kim on 3/1/21.
//

import UIKit
import SnapKit

final internal class DetailsViewController: UIViewController {
    private weak var collectionView: UICollectionView? = nil
    private var viewModel: DetailsViewModel? = nil
    
    deinit {
        printDeinitMessage()
    }
    
    override internal func viewDidLoad() {
        super.viewDidLoad()
        configureAttributes()
        configureCollectionView()
        configureViewModel()
    }
    
    override internal func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationItem.largeTitleDisplayMode = .never
    }
    
    internal func setLinkJusoData(_ linkJusoData: AddrLinkJusoData) {
        viewModel?.linkJusoData = linkJusoData
        viewModel?.loadData()
    }
    
    private func configureAttributes() {
        view.backgroundColor = .systemBackground
        title = Localizable.DORODORO.string
        tabBarItem.title = Localizable.TABBAR_SEARCH_VIEW_CONTROLLER_TITLE.string
    }
    
    private func configureCollectionView() {
        let layout: UICollectionViewCompositionalLayout = .init(sectionProvider: getSectionProvider())
        let collectionView: UICollectionView = .init(frame: .zero, collectionViewLayout: layout)
        self.collectionView = collectionView
        view.addSubview(collectionView)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        collectionView.backgroundColor = collectionView.backgroundView?.backgroundColor
        collectionView.delegate = self
    }
    
    private func configureViewModel() {
        viewModel = .init()
        viewModel?.dataSource = makeDataSource()
    }
    
    private func makeDataSource() -> DetailsViewModel.DataSource {
        guard let collectionView: UICollectionView = collectionView else {
            return .init()
        }
        
        let dataSource: DetailsViewModel.DataSource = .init(collectionView: collectionView) { [weak self] (collectionView, indexPath, item) -> UICollectionViewCell? in
            guard let self = self else { return nil }
            return collectionView.dequeueConfiguredReusableCell(using: self.getInfoCellRegisteration(), for: indexPath, item: item)
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
    
    private func getSectionProvider() -> UICollectionViewCompositionalLayoutSectionProvider {
        return { (section: Int, layoutEnvironment: NSCollectionLayoutEnvironment) -> NSCollectionLayoutSection? in
//            guard let self = self else { return nil }
//
//            if let coordSectionIndex: Int = self.viewModel?.dataSource?.snapshot().sectionIdentifiers.firstIndex(where: { $0.itemType == .map }),
//               coordSectionIndex == section {
//                let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
//                                                             heightDimension: .fractionalHeight(1.0))
//                let item: NSCollectionLayoutItem = .init(layoutSize: itemSize)
//                let groupSize: NSCollectionLayoutSize = .init(widthDimension: .fractionalWidth(1),
//                                                              heightDimension: .absolute(300))
//                let group: NSCollectionLayoutGroup = .horizontal(layoutSize: groupSize, subitems: [item])
//                return NSCollectionLayoutSection(group: group)
//            } else {
//                var configuration: UICollectionLayoutListConfiguration = .init(appearance: .insetGrouped)
//                configuration.headerMode = .supplementary
//                return NSCollectionLayoutSection.list(using: configuration, layoutEnvironment: layoutEnvironment)
//            }
            
            var configuration: UICollectionLayoutListConfiguration = .init(appearance: .insetGrouped)
            configuration.headerMode = .supplementary
            configuration.footerMode = .supplementary
            return NSCollectionLayoutSection.list(using: configuration, layoutEnvironment: layoutEnvironment)
        }
    }
    
    private func getInfoCellRegisteration() -> UICollectionView.CellRegistration<UICollectionViewListCell, DetailInfoItem> {
        return .init { (cell, indexPath, item) in
            switch item.itemType {
            case let .link(text, secondaryText):
                var configuration: UIListContentConfiguration = cell.defaultContentConfiguration()
                configuration.text = text
                configuration.secondaryText = secondaryText
                cell.contentConfiguration = configuration
            case let .eng(text, secondaryText):
                var configuration: UIListContentConfiguration = cell.defaultContentConfiguration()
                configuration.text = text
                configuration.secondaryText = secondaryText
                cell.contentConfiguration = configuration
            case let .map(latitude, longitude):
                cell.contentConfiguration = DetailsMapViewConfiguration(latitude: latitude, longitude: longitude)
            }
        }
    }
    
    private func getHeaderCellRegisteration() -> UICollectionView.SupplementaryRegistration<UICollectionViewListCell> {
        return .init(elementKind: UICollectionView.elementKindSectionHeader) { [weak self] (headerView, elementKind, indexPath) in
            guard let dataSource: DetailsViewModel.DataSource = self?.viewModel?.dataSource else {
                return
            }
            guard dataSource.snapshot().sectionIdentifiers.count > indexPath.section else { return }
            
            let headerItem: DetailHeaderItem = dataSource.snapshot().sectionIdentifiers[indexPath.section]
            
            var configuration: UIListContentConfiguration = headerView.defaultContentConfiguration()
            configuration.text = headerItem.itemType.rawValue
            headerView.contentConfiguration = configuration
        }
    }
    
    private func getFooterCellRegisteration() -> UICollectionView.SupplementaryRegistration<UICollectionViewListCell> {
        return .init(elementKind: UICollectionView.elementKindSectionFooter) { [weak self] (footerView, elementKind, indexPath) in
            guard let dataSource: DetailsViewModel.DataSource = self?.viewModel?.dataSource else {
                return
            }
            guard dataSource.snapshot().sectionIdentifiers.count > indexPath.section else { return }
            
            let headerItem: DetailHeaderItem = dataSource.snapshot().sectionIdentifiers[indexPath.section]
            
            switch headerItem.itemType {
            case .map:
                var configuration: UIListContentConfiguration = footerView.defaultContentConfiguration()
                #if arch(arm64) || targetEnvironment(simulator)
                configuration.text = "Powered by KakaoMap"
                #else
                configuration.text = "Powered by Apple Map"
                #endif
                footerView.contentConfiguration = configuration
            default:
                footerView.contentConfiguration = nil
            }
        }
    }
}

extension DetailsViewController: UICollectionViewDelegate {
    internal func collectionView(_ collectionView: UICollectionView, shouldHighlightItemAt indexPath: IndexPath) -> Bool {
        return false
    }
}
