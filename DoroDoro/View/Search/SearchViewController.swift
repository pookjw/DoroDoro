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

final internal class SearchViewController: UIViewController {
    private weak var collectionView: UICollectionView? = nil
    private weak var spinnerView: SpinnerView? = nil
    private weak var searchController: UISearchController? = nil
    private weak var slackLoadingAnimator: SlackLoadingAnimator? = nil
    private var viewModel: SearchViewModel? = nil
    private var cancellableBag: Set<AnyCancellable> = .init()
    
    private var inputText: String? {
        return searchController?.searchBar.searchTextField.text
    }
    
    override internal func viewDidLoad() {
        super.viewDidLoad()
        configureAttributes()
        configureCollectionView()
        configureSearchController()
        configureViewModel()
        bind()
    }
    
    override internal func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationItem.largeTitleDisplayMode = .always
        navigationController?.navigationBar.prefersLargeTitles = true
        animateForSelectedIndexPath(animated: animated)
    }
    
    private func configureViewModel() {
        viewModel = .init()
        viewModel?.dataSource = makeDataSource()
    }
    
    private func configureAttributes() {
        view.backgroundColor = .systemBackground
        title = Localizable.DORODORO.string
        tabBarItem.title = Localizable.TABBAR_SEARCH_VIEW_CONTROLLER_TITLE.string
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
        slackLoadingAnimator.isHidden = true
    }
    
    private func configureSearchController() {
        let searchController: UISearchController = .init(searchResultsController: nil)
        self.searchController = searchController
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.delegate = self
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = false
    }
    
    private func animateForSelectedIndexPath(animated: Bool) {
        collectionView?.indexPathsForSelectedItems?.forEach { [weak self] indexPath in
            if let coordinator: UIViewControllerTransitionCoordinator = self?.transitionCoordinator {
                coordinator.animate(alongsideTransition: { context in
                    self?.collectionView?.deselectItem(at: indexPath, animated: true)
                }, completion: { context in
                    if context.isCancelled {
                        self?.collectionView?.selectItem(at: indexPath, animated: false, scrollPosition: .left)
                    }
                })
            } else {
                self?.collectionView?.deselectItem(at: indexPath, animated: animated)
            }
        }
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
        return .init { (cell, indexPath, result) in
            var configuration: UIListContentConfiguration = cell.defaultContentConfiguration()
            configuration.text = result.linkJusoData.roadAddr
            configuration.image = UIImage(systemName: "signpost.right")
            cell.contentConfiguration = configuration
        }
    }
    
    private func getHeaderCellRegisteration() -> UICollectionView.SupplementaryRegistration<UICollectionViewListCell> {
        return .init(elementKind: UICollectionView.elementKindSectionHeader) { [weak self] (headerView, elementKind, indexPath) in
            guard let dataSource: SearchViewModel.DataSource = self?.viewModel?.dataSource else { return }
            guard dataSource.snapshot().sectionIdentifiers.count > indexPath.section else { return }
            
            let headerItem: SearchHeaderItem = dataSource.snapshot().sectionIdentifiers[indexPath.section]
            
            var configuration: UIListContentConfiguration = headerView.defaultContentConfiguration()
            configuration.text = headerItem.title
            headerView.contentConfiguration = configuration
        }
    }
    
    private func bind() {
        viewModel?.addrAPIService.linkErrorEvent
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] error in
                self?.showErrorAlert(for: error)
                self?.removeSpinnerView()
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
                
                self?.removeSpinnerView()
            })
            .store(in: &cancellableBag)
    }
    
    private func pushToDetailsVC(linkJusoData: AddrLinkJusoData) {
        let detailsVC: DetailsViewController = .init()
        detailsVC.loadViewIfNeeded()
        detailsVC.setLinkJusoData(linkJusoData)
        navigationController?.pushViewController(detailsVC, animated: true)
    }
    
    private func addSpinnerView() {
        removeSpinnerView()
        
        let spinnerView: SpinnerView = .init()
        self.spinnerView = spinnerView
        spinnerView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(spinnerView)
        spinnerView.snp.remakeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
    private func removeSpinnerView() {
        spinnerView?.removeFromSuperview()
        spinnerView = nil
    }
}

extension SearchViewController: UISearchBarDelegate {
    internal func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchController?.dismiss(animated: true, completion: nil)
        if let text: String = searchBar.text,
           !text.isEmpty {
            viewModel?.searchEvent = text
            addSpinnerView()
        }
    }
}

extension SearchViewController: UICollectionViewDelegate {
    internal func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        searchController?.searchBar.resignFirstResponder()
    }
    
    internal func collectionView(_ collectionView: UICollectionView, contextMenuConfigurationForItemAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
        
        guard let cell: UICollectionViewCell = collectionView.cellForItem(at: indexPath) else {
            return nil
        }
        
        guard let configuration: UIListContentConfiguration = cell.contentConfiguration as? UIListContentConfiguration else {
            return nil
        }
        
        guard let text: String = configuration.text else {
            return nil
        }
        
        guard let contextMenuLinkJusoData: AddrLinkJusoData = viewModel?.getResultItem(from: indexPath)?.linkJusoData else {
            return nil
        }
        
        let bookmarkAction = UIAction(title: Localizable.REMOVE_FROM_BOOKMARKS.string,
                                image: UIImage(systemName: "bookmark.fill"),
                                attributes: [.destructive]) { _ in
            // Perform action
        }
        
        let copyAction = UIAction(title: Localizable.COPY.string,
                             image: UIImage(systemName: "doc.on.doc")) { action in
            UIPasteboard.general.string = text
        }
        
        let shareAction = UIAction(title: Localizable.SHARE.string,
                              image: UIImage(systemName: "square.and.arrow.up")) { [weak self, weak cell] action in
            self?.share([text], sourceView: cell)
        }
        
        viewModel?.contextMenuLinkJusoData = contextMenuLinkJusoData
        
        return UIContextMenuConfiguration(identifier: nil,
                                          previewProvider: nil) { _ in
            UIMenu(title: "", children: [bookmarkAction, copyAction, shareAction])
        }
    }
    
    internal func collectionView(_ collectionView: UICollectionView, willPerformPreviewActionForMenuWith configuration: UIContextMenuConfiguration, animator: UIContextMenuInteractionCommitAnimating) {
        animator.addAnimations { [weak self] in
            if let data: AddrLinkJusoData = self?.viewModel?.contextMenuLinkJusoData {
                self?.pushToDetailsVC(linkJusoData: data)
            }
            self?.viewModel?.contextMenuLinkJusoData = nil
        }
    }
    
    internal func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let item: SearchResultItem = viewModel?.getResultItem(from: indexPath) else {
            return
        }
        pushToDetailsVC(linkJusoData: item.linkJusoData)
    }
}
