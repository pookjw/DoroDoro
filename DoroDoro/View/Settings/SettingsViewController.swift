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

final internal class SettingsViewController: UIViewController {
    private weak var collectionView: UICollectionView? = nil
    private weak var mailBarButtonItem: UIBarButtonItem? = nil
    private var viewModel: SettingsViewModel? = nil
    private weak var contextViewController: UIViewController? = nil
    
    override internal func viewDidLoad() {
        super.viewDidLoad()
        setAttributes()
        configureCollectionView()
        configureViewModel()
    }
    
    override internal func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if let collectionView: UICollectionView = collectionView {
            animateForSelectedIndexPath(collectionView, animated: animated)
        }
    }
    
    private func setAttributes() {
        view.backgroundColor = .systemBackground
        title = "SETTINGS"
        
        let mailBarButtonItem: UIBarButtonItem = .init(title: nil,
                                                       image: UIImage(systemName: "ant"),
                                                       primaryAction: getMailBarButtonAction(),
                                                       menu: nil)
        self.mailBarButtonItem = mailBarButtonItem
        navigationItem.rightBarButtonItems = [mailBarButtonItem]
    }
    
    private func configureViewModel() {
        viewModel = .init()
        viewModel?.dataSource = makeDataSource()
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
            }
        }
    }
    
    private func getHeaderCellRegisteration() -> UICollectionView.SupplementaryRegistration<UICollectionViewListCell> {
        return .init(elementKind: UICollectionView.elementKindSectionHeader) { [weak self] (headerView, elementKind, indexPath) in
            guard let dataSource: SettingsViewModel.DataSource = self?.viewModel?.dataSource else { return }
            guard dataSource.snapshot().sectionIdentifiers.count > indexPath.section else { return }
            
            guard let headerItem: SettingHeaderItem = self?.viewModel?.getSectionHeaderItem(from: indexPath) else {
                return
            }
            
            var configuration: UIListContentConfiguration = headerView.defaultContentConfiguration()
            
            switch headerItem.headerType {
            case .map:
                configuration.text = "MAPS(번역)"
            case .contributor:
                configuration.text = "Contributors(번역)"
            case .about:
                configuration.text = "정보(번역)"
            }
            headerView.contentConfiguration = configuration
        }
    }
    
    private func getFooterCellRegisteration() -> UICollectionView.SupplementaryRegistration<UICollectionViewListCell> {
        return .init(elementKind: UICollectionView.elementKindSectionFooter) { [weak self] (footerView, elementKind, indexPath) in
            guard let dataSource: SettingsViewModel.DataSource = self?.viewModel?.dataSource else {
                return
            }
            guard dataSource.snapshot().sectionIdentifiers.count > indexPath.section else { return }
            
            guard let headerItem: SettingHeaderItem = self?.viewModel?.getSectionHeaderItem(from: indexPath) else {
                return
            }
            
            switch headerItem.headerType {
            case .map:
                var configuration: UIListContentConfiguration = footerView.defaultContentConfiguration()
                
                configuration.text = "상세 보기 화면와 Intel CPU, 애플워치에서는 애플지도만 지원합니다.(번역)"
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
            configuration.text = "APPLE MAPS(번역)"
            configuration.image = UIImage(named: "kakaomap")
            configuration.imageProperties.cornerRadius = 25
            configuration.imageProperties.maximumSize = .init(width: 50, height: 50)
        case .kakaoMap:
            configuration.text = "KAKAO MAPS(번역)"
            configuration.image = UIImage(named: "applemaps")
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
        case .pookjw:
            configuration.image = UIImage(named: "pookjw")
            configuration.imageProperties.cornerRadius = 25
            configuration.imageProperties.maximumSize = .init(width: 50, height: 50)
            configuration.text = "김진우(번역필요)"
            configuration.secondaryText = "메인 개발자(번역필요)"
        }
        
        cell.contentConfiguration = configuration
        cell.accessories = [.disclosureIndicator()]
    }
    
    private func setAcknowledgementsTypeCell(cell: UICollectionViewListCell) {
        var configuration: UIListContentConfiguration = cell.defaultContentConfiguration()
        configuration.text = "오픈소스 고지 (번역필요)"
        configuration.secondaryText = "CocoaPods Open Source Library (번역필요)"
        configuration.image = UIImage(named: "cocoapods")
        configuration.imageProperties.cornerRadius = 25
        configuration.imageProperties.maximumSize = .init(width: 50, height: 50)
        cell.contentConfiguration = configuration
        cell.accessories = [.disclosureIndicator()]
    }
    
    private func setAppInfoCell(cell: UICollectionViewListCell, version: String?, build: String?) {
        var configuration: UIListContentConfiguration = cell.defaultContentConfiguration()
        configuration.text = "DoroDoro"
        configuration.image = UIImage(named: "logo")
        configuration.imageProperties.cornerRadius = 25
        configuration.imageProperties.maximumSize = .init(width: 50, height: 50)
        configuration.secondaryText = "\(version ?? "(unknown)") (\(build ?? "(unknown)"))"
        cell.contentConfiguration = configuration
        cell.accessories = []
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
    
    private func presentMFMailComposeVC() {
        guard MFMailComposeViewController.canSendMail() else {
            showErrorAlert(message: "(번역필요)이 기기에 등록된 이메일 주소가 없습니다.")
            return
        }
        
        let composeVC: MFMailComposeViewController = .init()
        composeVC.mailComposeDelegate = self
        composeVC.setToRecipients(["kidjinwoo@me.com"])
        composeVC.setSubject("(번역필요) DoroDoro 버그 제보")
        composeVC.setMessageBody("(번역필요) 테스트 빌드정보", isHTML: false)
        
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
                }
            }
        case .acknowledgements:
            presentAcknowledgementsVC()
        case .appinfo:
            break
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
            showErrorAlert(message: "(번역필요) 실패!")
        case .saved:
            break
        case .sent:
            showSuccessAlert(message: "(번역필요)성공!")
        @unknown default:
            break
        }
        
        controller.dismiss(animated: true, completion: nil)
    }
}
