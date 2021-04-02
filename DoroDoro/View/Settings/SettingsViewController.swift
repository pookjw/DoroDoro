//
//  SettingsViewController.swift
//  DoroDoro
//
//  Created by Jinwoo Kim on 2/25/21.
//

import UIKit
import SafariServices
import MessageUI
import AcknowList

internal final class SettingsViewController: UIViewController {
    private weak var collectionView: UICollectionView? = nil
    private weak var mailBarButtonItem: UIBarButtonItem? = nil
    private var viewModel: SettingsViewModel? = nil
    private weak var contextViewController: UIViewController? = nil
    
    internal override func viewDidLoad() {
        super.viewDidLoad()
        setAttributes()
        configureCollectionView()
        configureViewModel()
    }
    
    internal override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if let collectionView: UICollectionView = collectionView {
            animateForSelectedIndexPath(collectionView, animated: animated)
        }
    }
    
    internal func scrollCollectionViewToTop() {
        collectionView?.scrollToTop(animated: true)
    }
    
    private func setAttributes() {
        view.backgroundColor = .systemBackground
        title = Localizable.SETTINGS.string
        
        let mailBarButtonItem: UIBarButtonItem = .init(title: nil,
                                                       image: UIImage(systemName: "ant"),
                                                       primaryAction: getMailBarButtonAction(),
                                                       menu: nil)
        self.mailBarButtonItem = mailBarButtonItem
        navigationItem.rightBarButtonItems = [mailBarButtonItem]
    }
    
    private func configureViewModel() {
        let viewModel: SettingsViewModel = .init(dataSource: makeDataSource())
        self.viewModel = viewModel
    }
    
    private func configureCollectionView() {
        var layoutConfiguration: UICollectionLayoutListConfiguration = .init(appearance: .insetGrouped)
        layoutConfiguration.headerMode = .supplementary
        layoutConfiguration.footerMode = .supplementary
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
    
    private func makeDataSource() -> SettingsViewModel.DataSource {
        guard let collectionView: UICollectionView = collectionView else {
            return .init()
        }
        
        let dataSource: SettingsViewModel.DataSource = .init(collectionView: collectionView) { [weak self] (collectionView, indexPath, item) -> UICollectionViewCell? in
            guard let self = self else { return nil }
            return collectionView.dequeueConfiguredReusableCell(using: self.getCellRegisteration(), for: indexPath, item: item)
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
    
    private func getCellRegisteration() -> UICollectionView.CellRegistration<UICollectionViewListCell, SettingCellItem> {
        return .init { [weak self] (cell, indexPath, item) in
            switch item.cellType {
            case .mapSelection(let mapType, let selected):
                self?.setMapSelectionCell(cell: cell, mapType: mapType, selected: selected)
            case .contributor(let contributorType, _):
                self?.setContributorTypeCell(cell: cell, contributorType: contributorType)
            case .acknowledgements:
                self?.setAcknowledgementsTypeCell(cell: cell)
            case .appinfo(let version, let build):
                self?.setAppInfoCell(cell: cell, version: version, build: build)
            case .urlSchemesGuide:
                self?.setURLSchemesGuideCell(cell: cell)
            }
        }
    }
    
    private func getHeaderCellRegisteration() -> UICollectionView.SupplementaryRegistration<UICollectionViewListCell> {
        return .init(elementKind: UICollectionView.elementKindSectionHeader) { [weak self] (headerView, elementKind, indexPath) in
            guard let headerItem: SettingHeaderItem = self?.viewModel?.getHeaderItem(from: indexPath) else {
                return
            }
            
            var configuration: UIListContentConfiguration = headerView.defaultContentConfiguration()
            
            switch headerItem.headerType {
            case .map:
                configuration.text = Localizable.MAP_PROVIDERS.string
            case .about:
                configuration.text = Localizable.APP_INFO.string
            case .contributor:
                configuration.text = Localizable.CONTRIBUTORS.string
            }
            headerView.contentConfiguration = configuration
        }
    }
    
    private func getFooterCellRegisteration() -> UICollectionView.SupplementaryRegistration<UICollectionViewListCell> {
        return .init(elementKind: UICollectionView.elementKindSectionFooter) { [weak self] (footerView, elementKind, indexPath) in
            guard let headerItem: SettingHeaderItem = self?.viewModel?.getHeaderItem(from: indexPath) else {
                return
            }
            
            switch headerItem.headerType {
            case .map:
                var configuration: UIListContentConfiguration = footerView.defaultContentConfiguration()
                
                configuration.text = Localizable.MAP_PROVIDERS_DESCRIPTION.string
                configuration.textProperties.alignment = .center
                footerView.contentConfiguration = configuration
            default:
                footerView.contentConfiguration = nil
            }
        }
    }
    
    private func setMapSelectionCell(
        cell: UICollectionViewListCell,
        mapType: SettingsMapSelectionType,
        selected: Bool)
    {
        var configuration: UIListContentConfiguration = cell.defaultContentConfiguration()
        
        switch mapType {
        case .appleMaps:
            configuration.text = Localizable.APPLE_MAPS.string
            configuration.image = UIImage(named: "applemaps")
            configuration.imageProperties.cornerRadius = 25
            configuration.imageProperties.maximumSize = .init(width: 50, height: 50)
        case .kakaoMap:
            configuration.text = Localizable.KAKAO_MAP.string
            configuration.image = UIImage(named: "kakaomap")
            configuration.imageProperties.cornerRadius = 25
            configuration.imageProperties.maximumSize = .init(width: 50, height: 50)
        }
        
        if selected {
            cell.accessories = [.checkmark()]
        } else {
            cell.accessories = []
        }
        
        cell.contentConfiguration = configuration
    }
    
    private func setContributorTypeCell(cell: UICollectionViewListCell, contributorType: SettingsContributorType) {
        var configuration: UIListContentConfiguration = cell.defaultContentConfiguration()
        
        switch contributorType {
        case .pookjw(let name, let role):
            configuration.image = UIImage(named: "pookjw")
            configuration.imageProperties.cornerRadius = 25
            configuration.imageProperties.maximumSize = .init(width: 50, height: 50)
            configuration.text = name
            configuration.secondaryText = role
        }
        
        cell.contentConfiguration = configuration
        cell.accessories = [.disclosureIndicator()]
    }
    
    private func setAcknowledgementsTypeCell(cell: UICollectionViewListCell) {
        var configuration: UIListContentConfiguration = cell.defaultContentConfiguration()
        configuration.text = Localizable.OPEN_SOURCE_ACKNOWLEDGEMENTS.string
        configuration.secondaryText = Localizable.COCOAPODS.string
        configuration.image = UIImage(named: "cocoapods")
        configuration.imageProperties.cornerRadius = 25
        configuration.imageProperties.maximumSize = .init(width: 50, height: 50)
        cell.contentConfiguration = configuration
        cell.accessories = [.disclosureIndicator()]
    }
    
    private func setAppInfoCell(cell: UICollectionViewListCell, version: String, build: String) {
        var configuration: UIListContentConfiguration = cell.defaultContentConfiguration()
        configuration.text = Localizable.DORODORO.string
        configuration.image = UIImage(named: "logo")
        configuration.imageProperties.cornerRadius = 25
        configuration.imageProperties.maximumSize = .init(width: 50, height: 50)
        configuration.secondaryText = "\(version) (\(build))"
        cell.contentConfiguration = configuration
        cell.accessories = []
    }
    
    private func setURLSchemesGuideCell(cell: UICollectionViewListCell) {
        var configuration: UIListContentConfiguration = cell.defaultContentConfiguration()
        configuration.text = "URL 가이드"
        configuration.secondaryText = "URL Schemes"
        configuration.image = UIImage(named: "link")
        configuration.imageProperties.cornerRadius = 25
        configuration.imageProperties.maximumSize = .init(width: 50, height: 50)
        cell.contentConfiguration = configuration
        cell.accessories = [.disclosureIndicator()]
    }
    
    private func makeSFSafariVCPreview(url: URL) -> UIViewController {
        let vc: SFSafariViewController = .init(url: url)
        contextViewController = vc
        return vc
    }
    
    private func makeAcknowledgementsVCPreview() -> UIViewController? {
        guard let path: String = Bundle.main.path(forResource: "Pods-DoroDoro-acknowledgements", ofType: "plist") else {
            return nil
        }
        let vc: AcknowListViewController = .init(plistPath: path, style: .insetGrouped)
        contextViewController = vc
        return vc
    }
    
    private func presentAcknowledgementsVC() {
        guard let path: String = Bundle.main.path(forResource: "Pods-DoroDoro-acknowledgements", ofType: "plist") else {
            return
        }
        let vc: AcknowListViewController = .init(plistPath: path, style: .insetGrouped)
        navigationController?.pushViewController(vc, animated: true)
    }
    
    private func makeURLSchemesGuideVC() -> UIViewController {
        let vc: URLSchemesGuideViewController = .init()
        contextViewController = vc
        return vc
    }
    
    private func presentURLSchemesGuideVC() {
        let vc: URLSchemesGuideViewController = .init()
        navigationController?.pushViewController(vc, animated: true)
    }
    
    private func presentMFMailComposeVC() {
        guard MFMailComposeViewController.canSendMail() else {
            showErrorAlert(message: Localizable.EMAIL_ERROR_NO_REGISTERED_EMAILS_ON_DEVICE.string)
            return
        }
        
        let body: String = """
        
        \(Localizable.EMAIL_APP_INFO.string)
        \(Localizable.EMAIL_SYSTEM_INFO.string)
        """
        let formattedBody: String = String(format: body,
                                           "\(Bundle.main.releaseVersionNumber) (\(Bundle.main.buildVersionNumber))",
                                           "\(UIDevice.modelName)_\(UIDevice.current.systemVersion)")
        
        let composeVC: MFMailComposeViewController = .init()
        composeVC.mailComposeDelegate = self
        composeVC.setToRecipients(["kidjinwoo@me.com"])
        composeVC.setSubject(Localizable.EMAIL_TITLE.string)
        composeVC.setMessageBody(formattedBody, isHTML: false)
        composeVC.modalPresentationStyle = .fullScreen
        
        present(composeVC, animated: true, completion: nil)
    }
    
    private func getMailBarButtonAction() -> UIAction {
        return .init { [weak self] _ in
            self?.presentMFMailComposeVC()
        }
    }
}

extension SettingsViewController: UICollectionViewDelegate {
    internal func collectionView(_ collectionView: UICollectionView, shouldHighlightItemAt indexPath: IndexPath) -> Bool {
        guard let cellItem: SettingCellItem = viewModel?.getCellItem(from: indexPath) else {
             return false
        }
        
        switch cellItem.cellType {
        case .mapSelection:
            return true
        case .contributor:
            return true
        case .acknowledgements:
            return true
        case .appinfo:
            return false
        case .urlSchemesGuide:
            return true
        }
    }
    
    internal func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let cellItem: SettingCellItem = viewModel?.getCellItem(from: indexPath) else {
             return
        }
        
        switch cellItem.cellType {
        case .mapSelection(let mapType, _):
            viewModel?.updateMapSelection(new: mapType)
            collectionView.deselectItem(at: indexPath, animated: true)
        case .contributor(let contributorType, let url):
            switch contributorType {
            case .pookjw:
                if let url: URL = URL(string: url) {
                    presentSFSafariViewController(url)
                    #if targetEnvironment(macCatalyst)
                    collectionView.deselectItem(at: indexPath, animated: true)
                    #endif
                }
            }
        case .acknowledgements:
            presentAcknowledgementsVC()
        case .appinfo:
            break
        case .urlSchemesGuide:
            presentURLSchemesGuideVC()
        }
    }
    
    internal func collectionView(_ collectionView: UICollectionView, contextMenuConfigurationForItemAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
        guard let cellItem: SettingCellItem = viewModel?.getCellItem(from: indexPath) else {
             return nil
        }
        
        switch cellItem.cellType {
        case .contributor(let contributorType, let url):
            switch contributorType {
            case .pookjw:
                viewModel?.contextMenuIndexPath = indexPath
                return .init(identifier: nil,
                             previewProvider: { [weak self] () -> UIViewController? in
                                guard let url: URL = URL(string: url) else {
                                    return nil
                                }
                                return self?.makeSFSafariVCPreview(url: url)
                             },
                             actionProvider: nil)
            }
        case .acknowledgements:
            viewModel?.contextMenuIndexPath = indexPath
            return .init(identifier: nil,
                         previewProvider: { [weak self] () -> UIViewController? in
                            return self?.makeAcknowledgementsVCPreview()
                         },
                         actionProvider: nil)
        case .urlSchemesGuide:
            viewModel?.contextMenuIndexPath = indexPath
            return .init(identifier: nil,
                         previewProvider: { [weak self] () -> UIViewController? in
                            return self?.makeURLSchemesGuideVC()
                         },
                         actionProvider: nil)
        default:
            return nil
        }
    }
    
    internal func collectionView(_ collectionView: UICollectionView, willPerformPreviewActionForMenuWith configuration: UIContextMenuConfiguration, animator: UIContextMenuInteractionCommitAnimating) {
        if let indexPath: IndexPath = viewModel?.contextMenuIndexPath {
            collectionView.selectItem(at: indexPath, animated: true, scrollPosition: .centeredHorizontally)
            viewModel?.contextMenuIndexPath = nil
        }
        
        animator.addAnimations { [weak self] in
            if let vc: UIViewController = self?.contextViewController {
                if vc is SFSafariViewController {
                    self?.present(vc, animated: true, completion: nil)
                } else {
                    self?.navigationController?.pushViewController(vc, animated: true)
                }
                self?.contextViewController = nil
            }
        }
    }
}

extension SettingsViewController: MFMailComposeViewControllerDelegate {
    internal func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        guard error == nil else {
            if let error: Error = error {
                showErrorAlert(for: error)
            }
            return
        }
        
        switch result {
        case .cancelled:
            break
        case .failed:
            showErrorAlert(message: Localizable.ERROR.string)
        case .saved:
            break
        case .sent:
            showSuccessAlert(message: Localizable.EMAIL_SENT.string)
        @unknown default:
            break
        }
        
        controller.dismiss(animated: true, completion: nil)
    }
}
