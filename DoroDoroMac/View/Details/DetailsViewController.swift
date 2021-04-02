//
//  DetailsViewController.swift
//  DoroDoroMac
//
//  Created by Jinwoo Kim on 3/19/21.
//

import Cocoa
import Combine
import SnapKit
import DoroDoroMacAPI

internal final class DetailsViewController: NSViewController {
    private weak var visualEffectView: NSVisualEffectView? = nil
    private weak var tabView: NSTabView? = nil
    private weak var linkResultTabViewItem: NSTabViewItem? = nil
    private weak var engResultTabViewItem: NSTabViewItem? = nil
    private weak var mapResultTabViewItem: NSTabViewItem? = nil
    
    private var viewModel: DetailsViewModel? = nil
    private var cancellableBag: Set<AnyCancellable> = .init()
    
    internal override func loadView() {
        let view: NSView = .init()
        self.view = view
    }
    
    internal override func viewDidLoad() {
        super.viewDidLoad()
        configureVisualEffectView()
        configureTabView()
        configureViewModel()
        bind()
    }
    
    internal func setLinkJusoData(_ linkJusoData: AddrLinkJusoData) {
        viewModel?.loadData(linkJusoData)
    }
    
    internal func setRoadAddr(_ roadAddr: String) {
        showSpinnerView()
        viewModel?.loadData(roadAddr)
    }
    
    private func configureVisualEffectView() {
        let visualEffectView: NSVisualEffectView = .init()
        self.visualEffectView = visualEffectView
        visualEffectView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(visualEffectView)
        visualEffectView.snp.remakeConstraints { $0.edges.equalToSuperview() }
    }
    
    private func configureTabView() {
        guard let visualEffectView: NSVisualEffectView = visualEffectView else {
            return
        }
        
        let tabView: NSTabView = .init()
        self.tabView = tabView
        tabView.translatesAutoresizingMaskIntoConstraints = false
        visualEffectView.addSubview(tabView)
        tabView.snp.remakeConstraints { make in
            make.top.equalToSuperview().offset(20)
            make.bottom.equalToSuperview().offset(-20)
            make.leading.equalToSuperview().offset(20)
            make.trailing.equalToSuperview().offset(-20)
        }
    }
    
    private func configureViewModel() {
        let viewModel: DetailsViewModel = .init()
        self.viewModel = viewModel
    }
    
    private func bind() {
        viewModel?.linkResultItemEvent
            .prefix(1)
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] items in
                self?.configureLinkResult(items: items)
            })
            .store(in: &cancellableBag)
        
        viewModel?.engResultItemEvent
            .prefix(1)
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] items in
                self?.configureEngResult(items: items)
            })
            .store(in: &cancellableBag)
        
        viewModel?.mapResultItemEvent
            .prefix(1)
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] item in
                self?.configureMapResult(item: item)
            })
            .store(in: &cancellableBag)
        
        //
        
        viewModel?.refreshedEvent
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] in
                self?.removeAllSpinnerView()
            })
            .store(in: &cancellableBag)
        
        viewModel?.addrAPIService.linkErrorEvent
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] error in
                self?.removeAllSpinnerView()
                self?.showErrorAlert(for: error)
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
    }
    
    private func configureLinkResult(items: [DetailsListResultItem]) {
        guard let tabView: NSTabView = tabView else {
            return
        }
        
        let vc: DetailsListViewController = .init()
        vc.loadViewIfNeeded()
        vc.resultItems = items
        
        let linkResultTabViewItem: NSTabViewItem = .init(viewController: vc)
        self.linkResultTabViewItem = linkResultTabViewItem
        linkResultTabViewItem.label = Localizable.ADDR_LINK.string
        
        tabView.addTabViewItem(linkResultTabViewItem)
        tabView.selectTabViewItem(linkResultTabViewItem)
        sortTabViewItems()
    }
    
    private func configureEngResult(items: [DetailsListResultItem]) {
        guard let tabView: NSTabView = tabView else {
            return
        }
        
        let vc: DetailsListViewController = .init()
        vc.loadViewIfNeeded()
        vc.resultItems = items
        
        let engResultTabViewItem: NSTabViewItem = .init(viewController: vc)
        self.engResultTabViewItem = engResultTabViewItem
        engResultTabViewItem.label = Localizable.ADDR_ENG.string
        
        tabView.addTabViewItem(engResultTabViewItem)
        sortTabViewItems()
    }
    
    private func configureMapResult(item: DetailsMapResultItem) {
        guard let tabView: NSTabView = tabView else {
            return
        }
        
        let vc: DetailsMapViewController = .init()
        
        if let latitude: Double = item.latitude,
           let longitude: Double = item.longitude,
           let locationTitle: String = item.locationTitle {
            vc.latitude = latitude
            vc.longitude = longitude
            vc.locationTitle = locationTitle
        }
        
        vc.loadViewIfNeeded()
        
        let mapResultTabViewItem: NSTabViewItem = .init(viewController: vc)
        self.mapResultTabViewItem = mapResultTabViewItem
        mapResultTabViewItem.label = Localizable.MAP.string
        
        tabView.addTabViewItem(mapResultTabViewItem)
        sortTabViewItems()
    }
    
    private func sortTabViewItems() {
        let nullableItems: [NSTabViewItem?] = [linkResultTabViewItem, engResultTabViewItem, mapResultTabViewItem]
        let nonNullItems: [NSTabViewItem] = nullableItems.compactMap { $0 }
        tabView?.tabViewItems = nonNullItems
    }
}
