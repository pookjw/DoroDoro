//
//  BookmarksViewController.swift
//  DoroDoro
//
//  Created by Jinwoo Kim on 2/25/21.
//

import UIKit
import SnapKit
import Combine

final internal class BookmarksViewController: UIViewController {
    private weak var collectionView: UICollectionView? = nil
    private weak var guideContainerView: UIView? = nil
    private weak var guideBottomConstraint: Constraint? = nil
    private weak var guideLabel: UILabel? = nil
    private weak var searchController: UISearchController? = nil
    private var viewModel: BookmarksViewModel? = nil
    private var cancellableBag: Set<AnyCancellable> = .init()
    
    override internal func viewDidLoad() {
        super.viewDidLoad()
        setAttributes()
        configureGuideLabel()
        configureCollectionView()
        configureSearchController()
        configureViewModel()
        bind()
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
    
    private func configureSearchController() {
        let searchController: UISearchController = .init(searchResultsController: nil)
        self.searchController = searchController
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.delegate = self
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = false
    }
    
    private func configureViewModel() {
        viewModel = .init()
        viewModel?.dataSource = makeDataSource()
    }
    
    private func configureGuideLabel() {
        let guideContainerView: UIView = .init()
        self.guideContainerView = guideContainerView
        guideContainerView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(guideContainerView)
        guideContainerView.snp.remakeConstraints { [weak self] make in
            make.top.equalToSuperview()
            make.leading.equalToSuperview()
            make.trailing.equalToSuperview()
            let bottom: ConstraintMakerEditable = make.bottom.equalToSuperview()
            self?.guideBottomConstraint = bottom.constraint
        }
        guideContainerView.backgroundColor = .systemBackground
        
        let guideLabel: UILabel = .init()
        self.guideLabel = guideLabel
        guideContainerView.translatesAutoresizingMaskIntoConstraints = false
        guideContainerView.addSubview(guideLabel)
        guideLabel.snp.remakeConstraints { make in
            make.center.equalToSuperview()
        }
        guideLabel.textAlignment = .center
        guideLabel.textColor = .systemGray
        guideLabel.font = .preferredFont(forTextStyle: .title3)
        guideLabel.adjustsFontForContentSizeCategory = true
        guideLabel.text = "이거는 가이드 문구"
    }
    
    private func configureCollectionView() {
        // 이 View Controller에는 Section이 1개이므로 NSCollectionLayoutSection를 쓸 필요가 없다.
        let layoutConfiguration: UICollectionLayoutListConfiguration = .init(appearance: .insetGrouped)
        let layout: UICollectionViewCompositionalLayout = .list(using: layoutConfiguration)
        
        let collectionView: UICollectionView = .init(frame: .zero, collectionViewLayout: layout)
        self.collectionView = collectionView
        view.addSubview(collectionView)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.snp.remakeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        collectionView.backgroundColor = .systemBackground
        collectionView.isHidden = true
        collectionView.delegate = self
    }
    
    private func makeDataSource() -> BookmarksViewModel.DataSource {
        guard let collectionView: UICollectionView = collectionView else { return .init() }
        
        let dataSource: BookmarksViewModel.DataSource = .init(collectionView: collectionView) { [weak self] (collectionView, indexPath, result) -> UICollectionViewCell? in
            guard let self = self else { return nil }
            return collectionView.dequeueConfiguredReusableCell(using: self.getResultCellRegisteration(), for: indexPath, item: result)
        }
        
        return dataSource
    }
    
    private func getResultCellRegisteration() -> UICollectionView.CellRegistration<UICollectionViewListCell, BookmarksCellItem> {
        return .init { (cell, indexPath, result) in
            var configuration: UIListContentConfiguration = cell.defaultContentConfiguration()
            configuration.text = result.roadAddr
            configuration.image = UIImage(systemName: "signpost.right")
            cell.contentConfiguration = configuration
            cell.accessories = [.disclosureIndicator()]
        }
    }
    
    private func pushToDetailsVC(roadAddr: String) {
        let detailsVC: DetailsViewController = .init()
        detailsVC.loadViewIfNeeded()
        detailsVC.setRoadAddr(roadAddr)
        splitViewController?.showDetailViewController(detailsVC, sender: nil)
    }
    
    private func bind() {
        KeyboardEvent.shared.attributesEvent
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] (height, duration) in
                self?.guideBottomConstraint?.update(offset: -height)
                UIView.animate(withDuration: TimeInterval(duration)) { [weak self] in
                    self?.view.layoutIfNeeded()
                }
            })
            .store(in: &cancellableBag)
        
        viewModel?.refreshEvent
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] hasData in
                self?.guideContainerView?.isHidden = hasData
                self?.collectionView?.isHidden = !hasData
            })
            .store(in: &cancellableBag)
    }
}

extension BookmarksViewController: UICollectionViewDelegate {
    internal func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        searchController?.searchBar.resignFirstResponder()
    }
    
    internal func collectionView(_ collectionView: UICollectionView, contextMenuConfigurationForItemAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
        
        guard let cell: UICollectionViewCell = collectionView.cellForItem(at: indexPath) else {
            return nil
        }

        guard let roadAddr: String = viewModel?.getCellItem(from: indexPath)?.roadAddr else {
            return nil
        }
        
        
        //
        
        let bookmarkAction: UIAction
        
        if BookmarksService.shared.isBookmarked(roadAddr) {
            bookmarkAction = .init(title: Localizable.REMOVE_FROM_BOOKMARKS.string,
                                      image: UIImage(systemName: "bookmark.fill"),
                                      attributes: [.destructive]) { _ in
                BookmarksService.shared.removeBookmark(roadAddr)
              }
        } else {
            bookmarkAction = .init(title: Localizable.ADD_TO_BOOKMARKS.string,
                                      image: UIImage(systemName: "bookmark"),
                                      attributes: []) { _ in
                BookmarksService.shared.addBookmark(roadAddr)
              }
        }
        
        //
        
        let copyAction: UIAction = .init(title: Localizable.COPY.string,
                             image: UIImage(systemName: "doc.on.doc")) { action in
            UIPasteboard.general.string = roadAddr
        }
        
        let shareAction: UIAction = .init(title: Localizable.SHARE.string,
                              image: UIImage(systemName: "square.and.arrow.up")) { [weak self, weak cell] action in
            self?.share([roadAddr], sourceView: cell)
        }
        
        viewModel?.contextMenuIndexPath = indexPath
        viewModel?.contextMenuRoadAddr = roadAddr
        
        return UIContextMenuConfiguration(identifier: nil,
                                          previewProvider: nil) { _ in
            UIMenu(title: "", children: [bookmarkAction, copyAction, shareAction])
        }
    }
    
    internal func collectionView(_ collectionView: UICollectionView, willPerformPreviewActionForMenuWith configuration: UIContextMenuConfiguration, animator: UIContextMenuInteractionCommitAnimating) {
        animator.addAnimations { [weak self] in
            if let roadAddr: String = self?.viewModel?.contextMenuRoadAddr {
                self?.pushToDetailsVC(roadAddr: roadAddr)
                self?.viewModel?.contextMenuRoadAddr = nil
            }
        }
        
        if let indexPath: IndexPath = viewModel?.contextMenuIndexPath {
            collectionView.selectItem(at: indexPath, animated: true, scrollPosition: .centeredHorizontally)
            viewModel?.contextMenuIndexPath = nil
        }
    }
    
    internal func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let item: BookmarksCellItem = viewModel?.getCellItem(from: indexPath) else {
            return
        }
        pushToDetailsVC(roadAddr: item.roadAddr)
    }
}

extension BookmarksViewController: UISearchBarDelegate {
    internal func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        viewModel?.searchEvent = searchText
    }
    
    internal func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchController?.dismiss(animated: true, completion: nil)
    }
}
