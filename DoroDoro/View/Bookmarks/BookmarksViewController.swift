//
//  BookmarksViewController.swift
//  DoroDoro
//
//  Created by Jinwoo Kim on 2/25/21.
//

import UIKit
import SnapKit
import Combine

internal final class BookmarksViewController: UIViewController {
    private weak var collectionView: UICollectionView? = nil
    private weak var guideContainerView: UIView? = nil
    private weak var guideBottomConstraint: Constraint? = nil
    private weak var guideLabel: UILabel? = nil
    private weak var searchController: UISearchController? = nil
    private var viewModel: BookmarksViewModel? = nil
    private var cancellableBag: Set<AnyCancellable> = .init()
    
    internal override func viewDidLoad() {
        super.viewDidLoad()
        setAttributes()
        configureGuideLabel()
        configureCollectionView()
        configureSearchController()
        configureAccessiblity()
        configureViewModel()
        bind()
    }
    
    internal func scrollCollectionViewToTop() {
        collectionView?.scrollToTop(animated: true)
    }
    
    private func setAttributes() {
        view.backgroundColor = .systemBackground
        title = Localizable.BOOKMARKS.string
    }
    
    internal override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
//        navigationItem.largeTitleDisplayMode = .always
//        navigationController?.navigationBar.prefersLargeTitles = true
        
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
        let viewModel: BookmarksViewModel = .init(dataSource: makeDataSource())
        self.viewModel = viewModel
        collectionView?.reloadData()
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
        guideContainerView.backgroundColor = .clear
        
        let guideLabel: UILabel = .init()
        self.guideLabel = guideLabel
        guideContainerView.translatesAutoresizingMaskIntoConstraints = false
        guideContainerView.addSubview(guideLabel)
        guideLabel.snp.remakeConstraints { make in
            make.centerY.equalToSuperview()
            make.leading.equalToSuperview().offset(20)
            make.trailing.equalToSuperview().offset(-20)
        }
        guideLabel.textAlignment = .center
        guideLabel.textColor = .systemGray
        guideLabel.numberOfLines = 0
        guideLabel.font = .preferredFont(forTextStyle: .title3)
        guideLabel.adjustsFontForContentSizeCategory = true
        guideLabel.backgroundColor = .clear
        updateGuideLabelText(state: .noBookmarks)
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
    
    private func configureAccessiblity() {
        searchController?.searchBar.searchTextField.accessibilityLabel = Localizable.ACCESSIBILITY_BOOKMARKS_TEXTFIELD.string
        searchController?.searchBar.searchTextField.isAccessibilityElement = true
        
        guideLabel?.accessibilityLabel = Localizable.ACCESSIBILITY_BOOKMARKS_GUIDE.string
        guideContainerView?.accessibilityLabel = Localizable.ACCESSIBILITY_BOOKMARKS_GUIDE.string
        guideContainerView?.isAccessibilityElement = true
    }
    
    private func makeDataSource() -> BookmarksViewModel.DataSource {
        guard let collectionView: UICollectionView = collectionView else {
            fatalError("collectionViwe is nil!")
        }
        
        let resultCellRegistration: UICollectionView.CellRegistration<UICollectionViewListCell, BookmarksCellItem> = getResultCellRegisteration()
        
        let dataSource: BookmarksViewModel.DataSource = .init(collectionView: collectionView) { (collectionView, indexPath, result) -> UICollectionViewCell? in
            return collectionView.dequeueConfiguredReusableCell(using: resultCellRegistration, for: indexPath, item: result)
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
            .sink(receiveValue: { [weak self] (height, _) in
                self?.guideBottomConstraint?.update(offset: -height)
            })
            .store(in: &cancellableBag)
        
        viewModel?.refreshEvent
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] (hasData, hasResult) in
                self?.guideContainerView?.isHidden = hasData
                self?.collectionView?.isHidden = !hasData
                
                if let hasResult: Bool = hasResult, !hasResult {
                    self?.updateGuideLabelText(state: .noSearchResults)
                } else {
                    self?.updateGuideLabelText(state: .noBookmarks)
                }
            })
            .store(in: &cancellableBag)
    }
    
    private func updateGuideLabelText(state: BookmarksGuideLabelTextState) {
        switch state {
        case .noBookmarks:
            guideLabel?.text = Localizable.BOOKMARK_GUIDE_LABEL.string
        case .noSearchResults:
            guideLabel?.text = Localizable.NO_SEARCH_RESULTS.string
        }
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
            self?.share([roadAddr], sourceView: cell, showCompletionAlert: false)
        }
        
        viewModel?.contextMenuIndexPath = indexPath
        viewModel?.contextMenuRoadAddr = roadAddr
        
        return UIContextMenuConfiguration(identifier: nil,
                                          previewProvider: nil) { _ in
            UIMenu(title: "", children: [bookmarkAction, copyAction, shareAction])
        }
    }
    
    internal func collectionView(_ collectionView: UICollectionView, willPerformPreviewActionForMenuWith configuration: UIContextMenuConfiguration, animator: UIContextMenuInteractionCommitAnimating) {
        if let indexPath: IndexPath = viewModel?.contextMenuIndexPath {
            collectionView.selectItem(at: indexPath, animated: true, scrollPosition: .centeredHorizontally)
            viewModel?.contextMenuIndexPath = nil
        }
        
        animator.addAnimations { [weak self] in
            if let roadAddr: String = self?.viewModel?.contextMenuRoadAddr {
                self?.pushToDetailsVC(roadAddr: roadAddr)
                self?.viewModel?.contextMenuRoadAddr = nil
            }
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
