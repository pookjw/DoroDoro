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
    private weak var searchController: UISearchController? = nil
    private lazy var dataSource: DataSource = makeDataSource()
    private let viewModel: SearchViewModel = .init()
    private var cancellableBag: Set<AnyCancellable> = .init()
    
    typealias DataSource = UICollectionViewDiffableDataSource<SearchSectionItem, SearchResultItem>
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        configureAttributes()
        configureTableView()
        configureSearchController()
        bind()
    }
    
    private func configureAttributes() {
        navigationController?.navigationBar.prefersLargeTitles = true
        title = Localizable.DORODORO.string
    }
    
    private func configureTableView() {
        let collectionView: UICollectionView = .init(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
        self.collectionView = collectionView
        view.addSubview(collectionView)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        collectionView.backgroundColor = .systemBackground
        
        // 이 View Controller에는 Section이 1개이므로 NSCollectionLayoutSection를 쓸 필요가 없다.
        let configuration: UICollectionLayoutListConfiguration = .init(appearance: .insetGrouped)
        collectionView.collectionViewLayout = UICollectionViewCompositionalLayout.list(using: configuration)
    }
    
    private func configureSearchController() {
        let searchController: UISearchController = .init(searchResultsController: nil)
        self.searchController = searchController
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = true
        
        searchController
            .searchBar
            .searchTextField // UISearchTextField를 KVO해야 검색 버튼 눌렀을 때의 이벤트를 받아올 수 있다.
            .publisher(for: \.text)
            .sink(receiveValue: { [weak self] text in
                guard let text: String = text, !text.isEmpty else { return }
                APIService.shared.requestAddrLinkEvent(keyword: text)
                self?.searchController?.searchBar.resignFirstResponder()
                self?.searchController?.isActive = false
            })
            .store(in: &cancellableBag)
    }
    
    private func makeDataSource() -> DataSource {
        return DataSource(collectionView: collectionView) { (collectionView, indexPath, result) -> UICollectionViewCell? in
            return collectionView.dequeueConfiguredReusableCell(using: self.getResultCellRegisteration(), for: indexPath, item: result)
        }
    }
    
    private func getResultCellRegisteration() -> UICollectionView.CellRegistration<UICollectionViewListCell, SearchResultItem> {
        return .init { (cell, indexPath, result) in
            var configuration: UIListContentConfiguration = cell.defaultContentConfiguration()
            configuration.text = result.title
            cell.contentConfiguration = configuration
        }
    }
    
    private func bind() {
        APIService.shared.addrLinkEvent
            .sink(receiveValue: { [weak self] result in
                var snapshot: NSDiffableDataSourceSnapshot<SearchSectionItem, SearchResultItem> = .init()
                snapshot.appendSections([.results])
                result.juso.forEach { data in
                    let result: SearchResultItem = .init(title: data.roadAddr)
                    snapshot.appendItems([result], toSection: .results)
                }
                DispatchQueue.main.async {
                    self?.dataSource.apply(snapshot, animatingDifferences: true)
                }
            })
            .store(in: &cancellableBag)
    }
}
