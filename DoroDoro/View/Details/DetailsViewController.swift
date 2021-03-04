//
//  DetailsViewController.swift
//  DoroDoro
//
//  Created by Jinwoo Kim on 3/1/21.
//

import UIKit
import Combine
import SnapKit

final internal class DetailsViewController: UIViewController {
    private weak var collectionView: UICollectionView? = nil
    private weak var bookmarkButton: UIBarButtonItem? = nil
    private var viewModel: DetailsViewModel? = nil
    private var cancellableBag: Set<AnyCancellable> = .init()
    
    deinit {
        printDeinitMessage()
    }
    
    override internal func viewDidLoad() {
        super.viewDidLoad()
        setAttributes()
        configureCollectionView()
        configureViewModel()
        configureBookmarkButton()
        bind()
    }
    
    override internal func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationItem.largeTitleDisplayMode = .never
        title = "DETAILS"
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
        title = Localizable.DORODORO.string
        tabBarItem.title = Localizable.TABBAR_SEARCH_VIEW_CONTROLLER_TITLE.string
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
        viewModel = .init()
        viewModel?.dataSource = makeDataSource()
    }
    
    private func configureBookmarkButton() {
        let bookmarkButton: UIBarButtonItem = .init(title: nil,
                                                    image: nil,
                                                    primaryAction: getBookmarkButtonAction(),
                                                    menu: nil)
        self.bookmarkButton = bookmarkButton
        navigationItem.rightBarButtonItems = [bookmarkButton]
    }
    
    private func getBookmarkButtonAction() -> UIAction {
        return .init { [weak self] _ in
            self?.viewModel?.toggleBookmark()
        }
    }
    
    private func makeDataSource() -> DetailsViewModel.DataSource {
        guard let collectionView: UICollectionView = collectionView else {
            return .init()
        }
        
        let dataSource: DetailsViewModel.DataSource = .init(collectionView: collectionView) { [weak self] (collectionView, indexPath, item) -> UICollectionViewCell? in
            guard let self = self else { return nil }
            return collectionView.dequeueConfiguredReusableCell(using: self.getInfoCellRegisteration(), for: indexPath, item: item)
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
            }
        }
    }
    
    private func getHeaderCellRegisteration() -> UICollectionView.SupplementaryRegistration<UICollectionViewListCell> {
        return .init(elementKind: UICollectionView.elementKindSectionHeader) { [weak self] (headerView, elementKind, indexPath) in
            guard let dataSource: DetailsViewModel.DataSource = self?.viewModel?.dataSource else {
                return
            }
            guard dataSource.snapshot().sectionIdentifiers.count > indexPath.section else { return }
            
            let headerItem: DetailHeaderItem = dataSource.snapshot().sectionIdentifiers[indexPath.section]
            
            var configuration: UIListContentConfiguration = headerView.defaultContentConfiguration()
            configuration.text = String(headerItem.headerType.rawValue)
            headerView.contentConfiguration = configuration
        }
    }
    
    private func getFooterCellRegisteration() -> UICollectionView.SupplementaryRegistration<UICollectionViewListCell> {
        return .init(elementKind: UICollectionView.elementKindSectionFooter) { [weak self] (footerView, elementKind, indexPath) in
            guard let dataSource: DetailsViewModel.DataSource = self?.viewModel?.dataSource else {
                return
            }
            guard dataSource.snapshot().sectionIdentifiers.count > indexPath.section else { return }
            
            let headerItem: DetailHeaderItem = dataSource.snapshot().sectionIdentifiers[indexPath.section]
            
            switch headerItem.headerType {
            case .map:
                var configuration: UIListContentConfiguration = footerView.defaultContentConfiguration()
                
                configuration.text = "(번역필요) 행정안전부, 카카오에서 데이터를 제공했습니다."
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
        
        viewModel?.addrAPIService.engErrorEvent
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] error in
                self?.showErrorAlert(for: error)
            })
            .store(in: &cancellableBag)
        
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
            })
            .store(in: &cancellableBag)
    }
    
    private func presentMapView(corrd: (latitude: Double, longitude: Double), title: String? = nil) {
        let mapVC: MapViewController = .init()
        mapVC.latitude = corrd.latitude
        mapVC.longitude = corrd.longitude
        mapVC.locationText = title
        let mapNVC: UINavigationController = .init(rootViewController: mapVC)
        mapNVC.modalPresentationStyle = .fullScreen
        mapVC.loadViewIfNeeded()
        present(mapNVC, animated: true, completion: nil)
    }
}

extension DetailsViewController: UICollectionViewDelegate {
    internal func collectionView(_ collectionView: UICollectionView, shouldHighlightItemAt indexPath: IndexPath) -> Bool {
        guard let headerType: DetailHeaderItem.HeaderType = viewModel?.getSectionHeaderType(from: indexPath) else {
            return false
        }
        return headerType == .map
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
        
        guard let headerType: DetailHeaderItem.HeaderType = viewModel?.getSectionHeaderType(from: indexPath) else {
            return nil
        }
        
        switch headerType {
        case .link, .eng:
            guard let cell: UICollectionViewCell = collectionView.cellForItem(at: indexPath) else {
                return nil
            }
            
            guard let configuration: UIListContentConfiguration = cell.contentConfiguration as? UIListContentConfiguration else {
                return nil
            }
            
            guard let text: String = configuration.secondaryText,
                  text != Localizable.NO_DATA.string else {
                return nil
            }
            
            let copyAction = UIAction(title: Localizable.COPY.string,
                                 image: UIImage(systemName: "doc.on.doc")) { action in
                UIPasteboard.general.string = text
            }
            
            let shareAction = UIAction(title: Localizable.SHARE.string,
                                       image: UIImage(systemName: "square.and.arrow.up")) { [weak self, weak cell] action in
                self?.share([text], sourceView: cell)
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
