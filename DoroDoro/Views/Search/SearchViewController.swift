//
//  SearchViewController.swift
//  DoroDoro
//
//  Created by Jinwoo Kim on 2/25/21.
//

import UIKit
import Combine
import SnapKit

final class SearchViewController: UIViewController {
    private weak var collectionView: UICollectionView! = nil
    private weak var searchController: UISearchController! = nil
    private lazy var dataSource: DataSource = makeDataSource()
    private let viewModel: SearchViewModel = .init()
    private var cancellableBag: Set<AnyCancellable> = .init()
    
    private var inputText: String {
        return searchController?.searchBar.searchTextField.text ?? ""
    }
    
    typealias DataSource = UICollectionViewDiffableDataSource<SearchHeaderItem, SearchResultItem>
    typealias Snapshot = NSDiffableDataSourceSnapshot<SearchHeaderItem, SearchResultItem>
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureAttributes()
        configureTableView()
        configureSearchController()
        bind()
    }
    
    private func configureAttributes() {
        view.backgroundColor = .systemBackground
        navigationController?.navigationBar.prefersLargeTitles = true
        title = Localizable.DORODORO.string
        tabBarItem.title = Localizable.TABBAR_SEARCH_VIEW_CONTROLLER_TITLE.string
    }
    
    private func configureTableView() {
        // 이 View Controller에는 Section이 1개이므로 NSCollectionLayoutSection를 쓸 필요가 없다.
        var layoutConfiguration: UICollectionLayoutListConfiguration = .init(appearance: .insetGrouped)
        layoutConfiguration.headerMode = .supplementary
        let layout: UICollectionViewCompositionalLayout = .list(using: layoutConfiguration)
        
        let collectionView: UICollectionView = .init(frame: .zero, collectionViewLayout: layout)
        self.collectionView = collectionView
        view.addSubview(collectionView)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        collectionView.backgroundColor = .systemBackground
        
    }
    
    private func configureSearchController() {
        let searchController: UISearchController = .init(searchResultsController: nil)
        self.searchController = searchController
        searchController.obscuresBackgroundDuringPresentation = false
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = false
    }
    
    private func makeDataSource() -> DataSource {
        let dataSource: DataSource = .init(collectionView: collectionView) { [weak self] (collectionView, indexPath, result) -> UICollectionViewCell? in
            guard let self = self else { return nil }
            return collectionView.dequeueConfiguredReusableCell(using: self.getResultCellRegisteration(), for: indexPath, item: result)
        }
        
        dataSource.supplementaryViewProvider = { [weak self] (collectionView, elementKind, indexPath) -> UICollectionReusableView? in
            guard let self = self else { return nil }
            
            if elementKind == UICollectionView.elementKindSectionHeader {
                return self.collectionView.dequeueConfiguredReusableSupplementary(using: self.getHeaderCellRegisteration(), for: indexPath)
            }

            return nil
        }
        
        return dataSource
    }
    
    private func getResultCellRegisteration() -> UICollectionView.CellRegistration<UICollectionViewListCell, SearchResultItem> {
        return .init { (cell, indexPath, result) in
            var configuration: UIListContentConfiguration = cell.defaultContentConfiguration()
            configuration.text = result.title
            configuration.image = UIImage(systemName: "signpost.right")
            cell.contentConfiguration = configuration
        }
    }
    
    private func getHeaderCellRegisteration() -> UICollectionView.SupplementaryRegistration<UICollectionViewListCell> {
        return .init(elementKind: UICollectionView.elementKindSectionHeader) { [weak self] (cell, elementKind, indexPath) in
            guard let self = self else { return }
            
            let headerItem: SearchHeaderItem = self.dataSource.snapshot().sectionIdentifiers[indexPath.section]
            
            var configuration: UIListContentConfiguration = cell.defaultContentConfiguration()
            configuration.text = headerItem.title
            cell.contentConfiguration = configuration
        }
    }
    
    private func bind() {
        APIService.shared.addrLinkEvent
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] result in
                guard let self = self else { return }
                self.updateResultItems(result, text: self.inputText)
            })
            .store(in: &cancellableBag)
        
        APIService.shared.addrLinkErrorEvent
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] error in
                self?.showErrorAlert(for: error)
            })
            .store(in: &cancellableBag)
        
        searchController
            .searchBar
            .searchTextField // UISearchTextField를 KVO해야 검색 버튼 눌렀을 때의 이벤트를 받아올 수 있다.
            .publisher(for: \.text)
            .sink(receiveValue: { [weak self] text in
                guard let text: String = text, !text.isEmpty else { return }
                APIService.shared.requestAddrLinkEvent(keyword: text, countPerPage: 100)
                self?.searchController?.searchBar.resignFirstResponder()
                self?.searchController?.dismiss(animated: true)
            })
            .store(in: &cancellableBag)
    }
    
    private func showErrorAlert(for error: LocalizedError) {
        let alert: UIAlertController = .init(title: nil, message: error.errorDescription, preferredStyle: .alert)
        let doneAction: UIAlertAction = .init(title: Localizable.DONE.string, style: .default)
        alert.addAction(doneAction)
        present(alert, animated: true)
    }
    
    private func updateResultItems(_ result: AddrLinkResultsData, text: String) {
        var snapshot: Snapshot = dataSource.snapshot()
        
        let headerItem: SearchHeaderItem = {
            guard let headerItem: SearchHeaderItem = snapshot.sectionIdentifiers.first else {
                let headerItem: SearchHeaderItem = .init(title: String(format: Localizable.RESULTS_FOR_ADDRESS.string, text))
                snapshot.appendSections([headerItem])
                return headerItem
            }
            return headerItem
        }()
        
        let resultItem: [SearchResultItem] = snapshot.itemIdentifiers(inSection: headerItem)
        
        var items: [SearchResultItem] = []
        result.juso.forEach { data in
            let result: SearchResultItem = .init(title: data.roadAddr)
            items.append(result)
        }
        
        snapshot.deleteItems(resultItem)
        snapshot.appendItems(items, toSection: headerItem)
        dataSource.apply(snapshot, animatingDifferences: true)
    }
}
