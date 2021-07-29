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
import DoroDoroAPI

internal final class SearchViewController: UIViewController {
    private weak var collectionView: UICollectionView? = nil
    private weak var guideContainerView: UIView? = nil
    private weak var guideBottomConstraint: Constraint? = nil
    private weak var guideLabel: UILabel? = nil
    private weak var searchController: UISearchController? = nil
    private weak var geoBarButtonItem: UIBarButtonItem? = nil
    private weak var slackLoadingAnimator: SlackLoadingAnimator? = nil
    private var viewModel: SearchViewModel? = nil
    private var cancellableBag: Set<AnyCancellable> = .init()
    
    private var inputText: String? {
        return searchController?.searchBar.searchTextField.text
    }
    
    internal override func viewDidLoad() {
        super.viewDidLoad()
        setAttributes()
        configureGuideLabel()
        configureCollectionView()
        configureSearchController()
        configureAccessiblity()
        toggleGuideContainerViewHiddenStatus(false)
        configureViewModel()
        bind()
    }
    
    internal override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
//        navigationItem.largeTitleDisplayMode = .always
//        navigationController?.navigationBar.prefersLargeTitles = true
        
        if let collectionView: UICollectionView = collectionView {
            animateForSelectedIndexPath(collectionView, animated: animated)
        }
    }
    
    internal func scrollCollectionViewToTop() {
        collectionView?.scrollToTop(animated: true)
    }
    
    private func configureViewModel() {
        let viewModel: SearchViewModel = .init(dataSource: makeDataSource())
        self.viewModel = viewModel
        collectionView?.reloadData()
    }
    
    private func setAttributes() {
        view.backgroundColor = .systemBackground
        title = Localizable.SEARCH.string
        let geoBarButtonItem: UIBarButtonItem = .init(title: nil,
                                                      image: UIImage(systemName: "location"),
                                                      primaryAction: getGeoBarButtonAction(),
                                                      menu: nil)
        self.geoBarButtonItem = geoBarButtonItem
        navigationItem.rightBarButtonItems = [geoBarButtonItem]
    }
    
    private func getGeoBarButtonAction() -> UIAction {
        return .init { [weak self] _ in
            self?.requestGeoEventIfAvailable()
        }
    }
    
    private func requestGeoEventIfAvailable() {
        guard let viewModel: SearchViewModel = viewModel else {
            return
        }
        
        let requested: Bool = viewModel.requestGeoEventIfAvailable()
        
        if requested {
            showSpinnerView()
        }
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
        guideLabel.text = Localizable.SEARCH_GUIDE_LABEL.string
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
        searchController.searchBar.textContentType = .streetAddressLine1
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = false
    }
    
    private func configureAccessiblity() {
        searchController?.searchBar.searchTextField.accessibilityLabel = Localizable.ACCESSIBILITY_SEARCH_TEXTFIELD.string
        searchController?.searchBar.searchTextField.isAccessibilityElement = true
        
        guideLabel?.accessibilityLabel = Localizable.ACCESSIBILITY_SEARCH_GUIDE.string
        guideContainerView?.accessibilityLabel = Localizable.ACCESSIBILITY_SEARCH_GUIDE.string
        guideContainerView?.isAccessibilityElement = true
        
        geoBarButtonItem?.accessibilityLabel = Localizable.ACCESSIBILITY_SEARCH_CURRENT_LOCATION.string
        geoBarButtonItem?.isAccessibilityElement = true
        
        //
        
        searchController?.searchBar.searchTextField.accessibilityIdentifier = AccessibilityIdentifiers.SearchVC.searchField
    }
    
    private func toggleGuideContainerViewHiddenStatus(_ hidden: Bool) {
        guideContainerView?.isHidden = hidden
        collectionView?.isHidden = !hidden
    }
    
    private func makeDataSource() -> SearchViewModel.DataSource {
        guard let collectionView: UICollectionView = collectionView else {
            fatalError("collectionViwe is nil!")
        }
        
        let resultCellRegistration: UICollectionView.CellRegistration<UICollectionViewListCell, SearchResultItem> = getResultCellRegisteration()
        let headerCellRegistration: UICollectionView.SupplementaryRegistration<UICollectionViewListCell> = getHeaderCellRegisteration()
        
        let dataSource: SearchViewModel.DataSource = .init(collectionView: collectionView) { (collectionView, indexPath, result) -> UICollectionViewCell? in
            return collectionView.dequeueConfiguredReusableCell(using: resultCellRegistration, for: indexPath, item: result)
        }
        
        dataSource.supplementaryViewProvider = { [weak self] (collectionView, elementKind, indexPath) -> UICollectionReusableView? in
            guard let self = self else { return nil }
            
            if elementKind == UICollectionView.elementKindSectionHeader {
                return self.collectionView?.dequeueConfiguredReusableSupplementary(using: headerCellRegistration, for: indexPath)
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
            cell.accessories = [.disclosureIndicator()]
        }
    }
    
    private func getHeaderCellRegisteration() -> UICollectionView.SupplementaryRegistration<UICollectionViewListCell> {
        return .init(elementKind: UICollectionView.elementKindSectionHeader) { [weak self] (headerView, elementKind, indexPath) in
            guard let headerItem: SearchHeaderItem = self?.viewModel?.getHeaderItem(from: indexPath) else {
                return
            }
            
            var configuration: UIListContentConfiguration = headerView.defaultContentConfiguration()
            configuration.text = headerItem.title
            headerView.contentConfiguration = configuration
        }
    }
    
    private func bind() {
        KeyboardEvent.shared.attributesEvent
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] (height, _) in
                self?.guideBottomConstraint?.update(offset: -height)
            })
            .store(in: &cancellableBag)
        
        ShortcutService.shared.typeEvent
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] type in
                switch type {
                case .search(let text):
                    self?.search(for: text)
                case .searchCurrentLocation:
                    self?.requestGeoEventIfAvailable()
                default:
                    break
                }
            })
            .store(in: &cancellableBag)
        
        viewModel?.addrAPIService.linkErrorEvent
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] error in
                self?.showErrorAlert(for: error)
                self?.removeAllSpinnerView()
            })
            .store(in: &cancellableBag)
        
        viewModel?.refreshedEvent
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] (canLoadMore, hasData, isFirstPage) in
                self?.collectionView?.cr.endLoadingMore()
                if canLoadMore {
                    self?.collectionView?.cr.resetNoMore()
                    self?.slackLoadingAnimator?.isHidden = false
                } else {
                    self?.collectionView?.cr.noticeNoMoreData()
                    self?.slackLoadingAnimator?.isHidden = true
                }
                
                if hasData {
                    self?.toggleGuideContainerViewHiddenStatus(true)
                    if isFirstPage {
                        self?.collectionView?.scrollToTop(animated: false)
                    }
                } else {
                    self?.toggleGuideContainerViewHiddenStatus(false)
                }
                
                self?.removeAllSpinnerView()
            })
            .store(in: &cancellableBag)
        
        viewModel?.geoEvent
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] roadAddr in
                self?.removeAllSpinnerView()
                self?.pushToDetailsVC(roadAddr: roadAddr)
            })
            .store(in: &cancellableBag)
        
        viewModel?.geoAPIService.coordErrorEvent
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] error in
                switch error {
                case GeoAPIError.permissionDenined:
                    self?.showErrorAlert(for: error, onTap: {
                        self?.viewModel?.openAppSettings()
                    })
                case GeoAPIError.warnAllowPermission:
                    self?.showWarningAlert(for: error)
                default:
                    self?.showErrorAlert(for: error)
                }
                self?.removeAllSpinnerView()
            })
            .store(in: &cancellableBag)
        
        viewModel?.kakaoAPIService.coord2AddressErrorEvent
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] error in
                self?.showErrorAlert(for: error)
                self?.removeAllSpinnerView()
            })
            .store(in: &cancellableBag)
        
        viewModel?.$isGeoSearching
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] value in
                let systemName: String = value ? "location.fill" : "location"
                self?.geoBarButtonItem?.image = UIImage(systemName: systemName)
            })
            .store(in: &cancellableBag)
    }
    
    private func pushToDetailsVC(linkJusoData: AddrLinkJusoData) {
        let detailsVC: DetailsViewController = .init()
        detailsVC.loadViewIfNeeded()
        detailsVC.setLinkJusoData(linkJusoData)
        splitViewController?.showDetailViewController(detailsVC, sender: nil)
    }
    
    private func pushToDetailsVC(roadAddr: String) {
        let detailsVC: DetailsViewController = .init()
        detailsVC.loadViewIfNeeded()
        detailsVC.setRoadAddr(roadAddr)
        splitViewController?.showDetailViewController(detailsVC, sender: nil)
    }
    
    private func search(for text: String?) {
        if let text: String = text,
           !text.isEmpty {
            searchController?.searchBar.text = text
            viewModel?.searchEvent = text
            showSpinnerView()
        }
    }
}

extension SearchViewController: UISearchBarDelegate {
    internal func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchController?.dismiss(animated: true, completion: nil)
        search(for: searchBar.text)
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
        
        guard let contextMenuLinkJusoData: AddrLinkJusoData = viewModel?.getResultItem(from: indexPath)?.linkJusoData else {
            return nil
        }
        
        let roadAddr: String = contextMenuLinkJusoData.roadAddr
        
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
        
        viewModel?.contextMenuLinkJusoData = contextMenuLinkJusoData
        viewModel?.contextMenuIndexPath = indexPath
        
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
            if let data: AddrLinkJusoData = self?.viewModel?.contextMenuLinkJusoData {
                self?.pushToDetailsVC(linkJusoData: data)
                self?.viewModel?.contextMenuLinkJusoData = nil
            }
        }
    }
    
    internal func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let item: SearchResultItem = viewModel?.getResultItem(from: indexPath) else {
            return
        }
        pushToDetailsVC(linkJusoData: item.linkJusoData)
    }
}
