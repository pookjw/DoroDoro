//
//  SearchViewController.swift
//  DoroDoro
//
//  Created by Jinwoo Kim on 2/25/21.
//

import UIKit
import Combine
import SnapKit
import CRRefresh

final class SearchViewController: UIViewController {
    private weak var collectionView: UICollectionView? = nil
    private weak var searchController: UISearchController? = nil
    private weak var slackLoadingAnimator: SlackLoadingAnimator? = nil
    private var viewModel: SearchViewModel? = nil
    private var cancellableBag: Set<AnyCancellable> = .init()
    
    private var inputText: String? {
        return searchController?.searchBar.searchTextField.text
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureAttributes()
        configureTableView()
        configureViewModel()
        configureSearchController()
        bind()
    }
    
    private func configureViewModel() {
        viewModel = .init()
        viewModel?.dataSource = makeDataSource()
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
        collectionView.delegate = self
        
        let slackLoadingAnimator: SlackLoadingAnimator = .init()
        self.slackLoadingAnimator = slackLoadingAnimator
        collectionView.cr.addFootRefresh(animator: slackLoadingAnimator) { [weak self] in
            self?.viewModel?.requestNextPageIfAvailable()
        }
    }
    
    private func configureSearchController() {
        let searchController: UISearchController = .init(searchResultsController: nil)
        self.searchController = searchController
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.delegate = self
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = false
    }
    
    private func makeDataSource() -> SearchViewModel.DataSource {
        guard let collectionView: UICollectionView = collectionView else { return .init() }
        
        let dataSource: SearchViewModel.DataSource = .init(collectionView: collectionView) { [weak self] (collectionView, indexPath, result) -> UICollectionViewCell? in
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
    
    private func getResultCellRegisteration() -> UICollectionView.CellRegistration<UICollectionViewListCell, SearchResultItem> {
        return .init { [weak self] (cell, indexPath, result) in
            guard let self = self else { return }
            var configuration: UIListContentConfiguration = cell.defaultContentConfiguration()
            configuration.text = result.title
            configuration.image = UIImage(systemName: "signpost.right")
            cell.contentConfiguration = configuration
            
//            let interaction: UIContextMenuInteraction = .init(delegate: self)
//            cell.removeAllInteractions()
//            cell.addInteraction(interaction)
        }
    }
    
    private func getHeaderCellRegisteration() -> UICollectionView.SupplementaryRegistration<UICollectionViewListCell> {
        return .init(elementKind: UICollectionView.elementKindSectionHeader) { [weak self] (cell, elementKind, indexPath) in
            guard let dataSource: SearchViewModel.DataSource = self?.viewModel?.dataSource else { return }
            
            let headerItem: SearchHeaderItem = dataSource.snapshot().sectionIdentifiers[indexPath.section]
            
            var configuration: UIListContentConfiguration = cell.defaultContentConfiguration()
            configuration.text = headerItem.title
            cell.contentConfiguration = configuration
        }
    }
    
    private func bind() {
        APIService.shared.addrLinkErrorEvent
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] error in
                self?.showErrorAlert(for: error)
            })
            .store(in: &cancellableBag)
        
        viewModel?.refreshedEvent
            .sink(receiveValue: { [weak self] hasMoreData in
                self?.collectionView?.cr.endLoadingMore()
                
                if hasMoreData {
                    self?.collectionView?.cr.resetNoMore()
                    self?.slackLoadingAnimator?.isHidden = false
                } else {
                    self?.collectionView?.cr.noticeNoMoreData()
                    self?.slackLoadingAnimator?.isHidden = true
                }
            })
            .store(in: &cancellableBag)
    }
    
    private func showErrorAlert(for error: LocalizedError) {
        let alert: UIAlertController = .init(title: nil, message: error.errorDescription, preferredStyle: .alert)
        let doneAction: UIAlertAction = .init(title: Localizable.DONE.string, style: .default)
        alert.addAction(doneAction)
        present(alert, animated: true)
    }
}

extension SearchViewController: UISearchBarDelegate {
    internal func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchController?.dismiss(animated: true, completion: nil)
        if let text: String = searchBar.text,
           !text.isEmpty {
            viewModel?.searchEvent = text
        }
    }
}

extension SearchViewController: UICollectionViewDelegate {
    internal func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        searchController?.searchBar.resignFirstResponder()
    }
    
    internal func collectionView(_ collectionView: UICollectionView, contextMenuConfigurationForItemAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
        guard let item: SearchResultItem = viewModel?.getResultItem(from: indexPath) else {
            return nil
        }
        
        let bookmarkAction = UIAction(title: Localizable.REMOVE_FROM_BOOKMARKS.string,
                                image: UIImage(systemName: "bookmark.fill"),
                                attributes: [.destructive]) { _ in
            // Perform action
        }
        
        let copyAction = UIAction(title: Localizable.COPY.string,
                             image: UIImage(systemName: "doc.on.doc")) { action in
            // Perform action
        }
        
        let shareAction = UIAction(title: Localizable.SHARE.string,
                              image: UIImage(systemName: "square.and.arrow.up")) { action in
            // Perform action
        }
        
        return UIContextMenuConfiguration(identifier: nil,
                                          previewProvider: nil) { _ in
            UIMenu(title: "Actions", children: [bookmarkAction, copyAction, shareAction])
        }
    }
    
    internal func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
    }
}
