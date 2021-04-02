//
//  URLGuideViewController.swift
//  DoroDoro
//
//  Created by Jinwoo Kim on 4/2/21.
//

import UIKit

internal final class URLGuideViewController: UIViewController {
    private weak var collectionView: UICollectionView? = nil
    private var viewModel: URLGuideViewModel? = nil
    
    internal override func viewDidLoad() {
        super.viewDidLoad()
        setAttributes()
        configureCollectionView()
        configureViewModel()
    }
    
    private func setAttributes() {
        view.backgroundColor = .systemBackground
        title = Localizable.URL_GUIDE.string
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
    
    private func configureViewModel() {
        let viewModel: URLGuideViewModel = .init(dataSource: makeDataSource())
        self.viewModel = viewModel
        collectionView?.reloadData()
    }
    
    private func makeDataSource() -> URLGuideViewModel.DataSource {
        guard let collectionView: UICollectionView = collectionView else {
            return .init()
        }
        
        let dataSource: URLGuideViewModel.DataSource = .init(collectionView: collectionView) { [weak self] (collectionView, indexPath, item) -> UICollectionViewCell? in
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
    
    private func getCellRegisteration() -> UICollectionView.CellRegistration<UICollectionViewListCell, URLGuideCellItem> {
        return .init { (cell, indexPath, item) in
            var configuration: UIListContentConfiguration = cell.defaultContentConfiguration()
            configuration.text = item.cellType.rawValue
            cell.contentConfiguration = configuration
        }
    }
    
    private func getHeaderCellRegisteration() -> UICollectionView.SupplementaryRegistration<UICollectionViewListCell> {
        return .init(elementKind: UICollectionView.elementKindSectionHeader) { [weak self] (headerView, elementKind, indexPath) in
            guard let headerItem: URLGuideHeaderItem = self?.viewModel?.getHeaderItem(from: indexPath) else {
                return
            }
            
            var configuration: UIListContentConfiguration = headerView.defaultContentConfiguration()
            switch headerItem.headerType {
            case .search:
                configuration.text = Localizable.URL_GUIDE_HEADER_SEARCH.string
            case .searchWithText:
                configuration.text = Localizable.URL_GUIDE_HEADER_SEARCH_WITH_TEXT.string
            case .searchCurrentLocation:
                configuration.text = Localizable.URL_GUIDE_HEADER_SEARCH_CURRENT_LOCATION.string
            case .bookmarks:
                configuration.text = Localizable.URL_GUIDE_HEADER_BOOKMAKRS.string
            }
            headerView.contentConfiguration = configuration
        }
    }
    
    private func getFooterCellRegisteration() -> UICollectionView.SupplementaryRegistration<UICollectionViewListCell> {
        return .init(elementKind: UICollectionView.elementKindSectionFooter) { [weak self] (headerView, elementKind, indexPath) in
            guard let headerItem: URLGuideHeaderItem = self?.viewModel?.getHeaderItem(from: indexPath) else {
                return
            }
            
            var configuration: UIListContentConfiguration = headerView.defaultContentConfiguration()
            switch headerItem.headerType {
            case .search:
                configuration.text = Localizable.URL_GUIDE_FOOTER_SEARCH.string
            case .searchWithText:
                configuration.text = Localizable.URL_GUIDE_FOOTER_SEARCH_WITH_TEXT.string
            case .searchCurrentLocation:
                configuration.text = Localizable.URL_GUIDE_FOOTER_SEARCH_CURRENT_LOCATION.string
            case .bookmarks:
                configuration.text = Localizable.URL_GUIDE_FOOTER_BOOKMARKS.string
            }
            headerView.contentConfiguration = configuration
        }
    }
}

extension URLGuideViewController: UICollectionViewDelegate {
    internal func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        defer {
            collectionView.deselectItem(at: indexPath, animated: true)
        }
        
        guard let cellItem: URLGuideCellItem = viewModel?.getCellItem(from: indexPath) else {
            return
        }
        
        UIPasteboard.general.string = cellItem.cellType.rawValue
        showSuccessAlert(title: Localizable.COPIED.string)
    }
}
