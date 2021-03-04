//
//  BookmarksViewController.swift
//  DoroDoro
//
//  Created by Jinwoo Kim on 2/25/21.
//

import UIKit

final internal class BookmarksViewController: UIViewController {
    private weak var collectionView: UICollectionView? = nil
    private var viewModel: BookmarksViewModel? = nil
    
    override internal func viewDidLoad() {
        super.viewDidLoad()
        setAttributes()
        configureCollectionView()
        configureViewModel()
    }
    
    private func setAttributes() {
        view.backgroundColor = .systemBackground
        title = "책갈피(번역)"
        tabBarItem.title = Localizable.TABBAR_SEARCH_VIEW_CONTROLLER_TITLE.string
    }
    
    override internal func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationItem.largeTitleDisplayMode = .always
        navigationController?.navigationBar.prefersLargeTitles = true
        
        if let collectionView: UICollectionView = collectionView {
            animateForSelectedIndexPath(collectionView, animated: animated)
        }
    }
    
    private func configureViewModel() {
        viewModel = .init()
        viewModel?.dataSource = makeDataSource()
    }
    
    private func configureCollectionView() {
        // 이 View Controller에는 Section이 1개이므로 NSCollectionLayoutSection를 쓸 필요가 없다.
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
    
    private func makeDataSource() -> BookmarksViewModel.DataSource {
        guard let collectionView: UICollectionView = collectionView else { return .init() }
        
        let dataSource: BookmarksViewModel.DataSource = .init(collectionView: collectionView) { [weak self] (collectionView, indexPath, result) -> UICollectionViewCell? in
            guard let self = self else { return nil }
            return collectionView.dequeueConfiguredReusableCell(using: self.getResultCellRegisteration(), for: indexPath, item: result)
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
    
    private func getResultCellRegisteration() -> UICollectionView.CellRegistration<UICollectionViewListCell, BookmarksCellItem> {
        return .init { (cell, indexPath, result) in
            var configuration: UIListContentConfiguration = cell.defaultContentConfiguration()
            configuration.text = result.roadAddr
            configuration.image = UIImage(systemName: "signpost.right")
            cell.contentConfiguration = configuration
        }
    }
    
    private func getHeaderCellRegisteration() -> UICollectionView.SupplementaryRegistration<UICollectionViewListCell> {
        return .init(elementKind: UICollectionView.elementKindSectionHeader) { [weak self] (headerView, elementKind, indexPath) in
            guard let dataSource: BookmarksViewModel.DataSource = self?.viewModel?.dataSource else { return }
            guard dataSource.snapshot().sectionIdentifiers.count > indexPath.section else { return }
            
            let headerItem: BookmarksHeaderItem = dataSource.snapshot().sectionIdentifiers[indexPath.section]
            
            var configuration: UIListContentConfiguration = headerView.defaultContentConfiguration()
            configuration.text = "DEMO"
            headerView.contentConfiguration = configuration
        }
    }
}

extension BookmarksViewController: UICollectionViewDelegate {
    
}
