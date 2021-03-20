//
//  DetailsViewController.swift
//  DoroDoroMac
//
//  Created by Jinwoo Kim on 3/19/21.
//

import Cocoa
import MapKit
import Combine
import SnapKit
import DoroDoroMacAPI

internal final class DetailsViewController: NSViewController {
    private weak var visualEffectView: NSVisualEffectView? = nil
    private weak var tabView: NSTabView? = nil
    
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
        tabView.snp.remakeConstraints { $0.edges.equalToSuperview() }
    }
    
    private func configureViewModel() {
        viewModel = .init()
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
        vc.dataSource = items
        tabView.addTabViewItem(.init(viewController: vc))
    }
    
    private func configureEngResult(items: [DetailsListResultItem]) {
        guard let tabView: NSTabView = tabView else {
            return
        }
        let vc: DetailsListViewController = .init()
        vc.loadViewIfNeeded()
        vc.dataSource = items
        tabView.addTabViewItem(.init(viewController: vc))
    }
    
    private func configureMapResult(item: DetailsMapResultItem) {
        
    }
}
