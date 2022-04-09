//
//  DetailsViewController.swift
//  DoroDoro
//
//  Created by Jinwoo Kim on 3/1/21.
//

import UIKit
import Foundation
import Combine
import SnapKit
import DoroDoroAPI

internal final class DetailsViewController: UIViewController {
    private weak var collectionView: UICollectionView? = nil
    private weak var bookmarkButton: UIBarButtonItem? = nil
    private var viewModel: DetailsViewModel? = nil
    private var cancellableBag: Set<AnyCancellable> = .init()
    
    internal override func viewDidLoad() {
        super.viewDidLoad()
        setAttributes()
        configureCollectionView()
        configureViewModel()
        configureBookmarkButton()
        configureAccessiblity()
        bind()
    }
    
    internal func setLinkJusoData(_ linkJusoData: AddrLinkJusoData) {
        viewModel?.loadData(linkJusoData)
    }
    
    internal func setRoadAddr(_ roadAddr: String) {
        showSpinnerView()
        viewModel?.loadData(roadAddr)
    }
    
    private func setAttributes() {
        view.backgroundColor = .systemBackground
        title = Localizable.DETAILS.string
        tabBarItem.title = Localizable.SEARCH.string
    }
    
    private func configureCollectionView() {
        let layout: UICollectionViewCompositionalLayout = .init(sectionProvider: getSectionProvider())
        let collectionView: UICollectionView = .init(frame: .zero, collectionViewLayout: layout)
        self.collectionView = collectionView
        view.addSubview(collectionView)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.snp.remakeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        collectionView.backgroundColor = collectionView.backgroundView?.backgroundColor
        collectionView.delegate = self
    }
    
    private func configureViewModel() {
        let viewModel: DetailsViewModel = .init(dataSource: makeDataSource())
        self.viewModel = viewModel
        collectionView?.reloadData()
    }
    
    private func configureBookmarkButton() {
        let bookmarkButton: UIBarButtonItem = .init(title: nil,
                                                    image: nil,
                                                    primaryAction: getBookmarkButtonAction(),
                                                    menu: nil)
        self.bookmarkButton = bookmarkButton
        navigationItem.rightBarButtonItems = [bookmarkButton]
    }
    
    private func configureAccessiblity() {
        /* bookmarkButton에 대한 접근성 문구와 Map Cell의 접근성 문구는 여기서 처리하지 않는다. */
        bookmarkButton?.isAccessibilityElement = true
    }
    
    private func getBookmarkButtonAction() -> UIAction {
        return .init { [weak self] _ in
            self?.viewModel?.toggleBookmark()
        }
    }
    
    private func makeDataSource() -> DetailsViewModel.DataSource {
        guard let collectionView: UICollectionView = collectionView else {
            fatalError("collectionViwe is nil!")
        }
        
        let infoCellRegistration: UICollectionView.CellRegistration<UICollectionViewListCell, DetailResultItem> = getInfoCellRegisteration()
        let headerCellRegistration: UICollectionView.SupplementaryRegistration<UICollectionViewListCell> = getHeaderCellRegisteration()
        let footerCellRegistration: UICollectionView.SupplementaryRegistration<UICollectionViewListCell> = getFooterCellRegisteration()
        
        let dataSource: DetailsViewModel.DataSource = .init(collectionView: collectionView) { (collectionView, indexPath, item) -> UICollectionViewCell? in
            return collectionView.dequeueConfiguredReusableCell(using: infoCellRegistration, for: indexPath, item: item)
        }
        
        dataSource.supplementaryViewProvider = { [weak self] (collectionView, elementKind, indexPath) -> UICollectionReusableView? in
            guard let self = self else { return nil }
            
            if elementKind == UICollectionView.elementKindSectionHeader {
                return self.collectionView?.dequeueConfiguredReusableSupplementary(using: headerCellRegistration, for: indexPath)
            } else if elementKind == UICollectionView.elementKindSectionFooter {
                return self.collectionView?.dequeueConfiguredReusableSupplementary(using: footerCellRegistration, for: indexPath)
            }
            
            return nil
        }
        
        return dataSource
    }
    
    private func getSectionProvider() -> UICollectionViewCompositionalLayoutSectionProvider {
        return { (section: Int, layoutEnvironment: NSCollectionLayoutEnvironment) -> NSCollectionLayoutSection? in
            var configuration: UICollectionLayoutListConfiguration = .init(appearance: .insetGrouped)
            configuration.headerMode = .supplementary
            configuration.footerMode = .supplementary
            return NSCollectionLayoutSection.list(using: configuration, layoutEnvironment: layoutEnvironment)
        }
    }
    
    private func getInfoCellRegisteration() -> UICollectionView.CellRegistration<UICollectionViewListCell, DetailResultItem> {
        return .init { (cell, indexPath, item) in
            switch item.resultType {
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
            case let .map(latitude, longitude, title):
                cell.contentConfiguration = DetailsMapViewConfiguration(latitude: latitude, longitude: longitude, title: title)
                cell.isAccessibilityElement = true
                cell.accessibilityLabel = Localizable.ACCESSIBILITY_DETAILS_MAP.string
            }
        }
    }
    
    private func getHeaderCellRegisteration() -> UICollectionView.SupplementaryRegistration<UICollectionViewListCell> {
        return .init(elementKind: UICollectionView.elementKindSectionHeader) { [weak self] (headerView, elementKind, indexPath) in
            
            guard let headerItem: DetailHeaderItem = self?.viewModel?.getHeaderItem(from: indexPath) else {
                return
            }
            
            var configuration: UIListContentConfiguration = .groupedHeader()
            
            switch headerItem.headerType {
            case .link:
                configuration.text = Localizable.ADDR_LINK.string
            case .eng:
                configuration.text = Localizable.ADDR_ENG.string
            case .map:
                configuration.text = Localizable.MAP.string
            }
            
            headerView.contentConfiguration = configuration
        }
    }
    
    private func getFooterCellRegisteration() -> UICollectionView.SupplementaryRegistration<UICollectionViewListCell> {
        return .init(elementKind: UICollectionView.elementKindSectionFooter) { [weak self] (footerView, elementKind, indexPath) in
            
            guard let headerItem: DetailHeaderItem = self?.viewModel?.getHeaderItem(from: indexPath) else {
                return
            }
            
            switch headerItem.headerType {
            case .map:
                var configuration: UIListContentConfiguration = .groupedFooter()
                
                configuration.text = Localizable.DATA_PROVIDER_DESCRIPTION.string
                configuration.textProperties.alignment = .center
                footerView.contentConfiguration = configuration
            default:
                footerView.contentConfiguration = nil
            }
        }
    }
    
    private func bind() {
        viewModel?.refreshedEvent
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] in
                self?.removeAllSpinnerView()
            })
            .store(in: &cancellableBag)
        
        viewModel?.addrAPIService.linkErrorEvent
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] error in
                self?.showErrorAlert(for: error)
                self?.removeAllSpinnerView()
            })
            .store(in: &cancellableBag)
        
//        viewModel?.addrAPIService.engErrorEvent
//            .receive(on: DispatchQueue.main)
//            .sink(receiveValue: { [weak self] error in
//                self?.showErrorAlert(for: error)
//            })
//            .store(in: &cancellableBag)
        
        viewModel?.kakaoAPIService.addressErrorEvent
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] error in
                self?.showErrorAlert(for: error)
            })
            .store(in: &cancellableBag)
        
        viewModel?.bookmarkEvent
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] status in
                self?.bookmarkButton?.image = status ? UIImage(systemName: "bookmark.fill") : UIImage(systemName: "bookmark")
                self?.bookmarkButton?.accessibilityLabel = status ? Localizable.ACCESSIBILITY_REMOVE_FROM_BOOKMARK.string : Localizable.ACCESSIBILITY_ADD_TO_BOOKMARK.string
            })
            .store(in: &cancellableBag)
    }
    
    private func presentMapView(corrd: (latitude: Double, longitude: Double), title: String? = nil) {
        let mapVC: MapViewController = .init()
        mapVC.latitude = corrd.latitude
        mapVC.longitude = corrd.longitude
        mapVC.locationText = title
        mapVC.loadViewIfNeeded()
        let mapNVC: UINavigationController = .init(rootViewController: mapVC)
        mapNVC.modalPresentationStyle = .pageSheet
        mapNVC.isModalInPresentation = true
        
        let appearance: UINavigationBarAppearance = .init()
        appearance.configureWithOpaqueBackground()
        mapNVC.navigationBar.standardAppearance = appearance
        mapNVC.navigationBar.scrollEdgeAppearance = appearance
        mapNVC.loadViewIfNeeded()
        present(mapNVC, animated: true, completion: { [weak mapNVC] in
            mapNVC?
                .presentationController?
                .presentedView?
                .gestureRecognizers?
                .filter { String(describing: $0).contains("_UISheetInteractionBackgroundDismissRecognizer") }
                .forEach { gesture in
                    gesture.isEnabled = false
                }
        })
    }
    
    private func pushToDetailsVC(roadAddr: String) {
        let detailsVC: DetailsViewController = .init()
        detailsVC.loadViewIfNeeded()
        detailsVC.setRoadAddr(roadAddr)
        splitViewController?.showDetailViewController(detailsVC, sender: nil)
    }
}

extension DetailsViewController: UICollectionViewDelegate {
    internal func collectionView(_ collectionView: UICollectionView, shouldHighlightItemAt indexPath: IndexPath) -> Bool {
        guard let headerItem: DetailHeaderItem = viewModel?.getHeaderItem(from: indexPath) else {
            return false
        }
        return headerItem.headerType == .map
    }
    
    internal func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let item: DetailResultItem = viewModel?.getResultItem(from: indexPath) else {
            return
        }
        
        guard case let .map(latitude, longitude, title) = item.resultType else {
            return
        }
        
        presentMapView(corrd: (latitude: latitude, longitude: longitude), title: title)
    }
    
    internal func collectionView(_ collectionView: UICollectionView, contextMenuConfigurationForItemAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
        
        guard let headerItem: DetailHeaderItem = viewModel?.getHeaderItem(from: indexPath) else {
            return nil
        }
        
        switch headerItem.headerType {
        case .link, .eng:
            guard let cell: UICollectionViewCell = collectionView.cellForItem(at: indexPath) else {
                return nil
            }
            
            guard let text: String = {
                guard let resultItem: DetailResultItem = viewModel?.getResultItem(from: indexPath) else {
                    return nil
                }
                
                switch resultItem.resultType {
                case let .link(_, text):
                    return (text == Localizable.NO_DATA.string) ? nil : text
                case let .eng(_, text):
                    return (text == Localizable.NO_DATA.string) ? nil : text
                default:
                    return nil
                }
            }() else {
                return nil
            }
            
            let copyAction = UIAction(title: Localizable.COPY.string,
                                 image: UIImage(systemName: "doc.on.doc")) { action in
                UIPasteboard.general.string = text
            }
            
            let shareAction = UIAction(title: Localizable.SHARE.string,
                                       image: UIImage(systemName: "square.and.arrow.up")) { [weak self, weak cell] action in
                self?.share([text], sourceView: cell, showCompletionAlert: false)
            }
            
            return UIContextMenuConfiguration(identifier: nil,
                                              previewProvider: nil) { _ in
                UIMenu(title: "", children: [copyAction, shareAction])
            }
        default:
            return nil
        }
    }
}
