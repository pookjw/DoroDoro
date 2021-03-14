//
//  SearchViewController.swift
//  DoroDoroMac
//
//  Created by Jinwoo Kim on 3/14/21.
//

import Cocoa
import Combine
import SnapKit

internal final class SearchViewController: NSViewController {
    private weak var visualEffectView: NSVisualEffectView? = nil
    private weak var searchField: NSSearchField? = nil
    private weak var separatorView: NSView? = nil
    private weak var tableView: NSTableView? = nil
    private weak var scrollView: NSScrollView? = nil
    private var searchIdentifier: NSUserInterfaceItemIdentifier? = nil
    private weak var searchColumn: NSTableColumn? = nil
    private var viewModel: SearchViewModel? = nil
    private var cancellableBag: Set<AnyCancellable> = .init()
    
    internal override func loadView() {
        let view: NSView = .init()
        self.view = view
    }
    
    internal override func viewDidLoad() {
        super.viewDidLoad()
        configureVisualEffectView()
        configureSearchField()
        configureSeparatorView()
        configureTableView()
        configureViewModel()
        bind()
    }
    
    private func configureVisualEffectView() {
        let visualEffectView: NSVisualEffectView = .init()
        self.visualEffectView = visualEffectView
        visualEffectView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(visualEffectView)
        visualEffectView.snp.remakeConstraints { $0.edges.equalToSuperview() }
    }
    
    private func configureSearchField() {
        guard let visualEffectView: NSVisualEffectView = visualEffectView else {
            return
        }
        
        let searchField: NSSearchField = .init()
        self.searchField = searchField
        searchField.delegate = self
        searchField.translatesAutoresizingMaskIntoConstraints = false
        visualEffectView.addSubview(searchField)
        searchField.snp.remakeConstraints { make in
            make.top.equalToSuperview().offset(30)
            make.leading.equalToSuperview().offset(10)
            make.trailing.equalToSuperview().offset(-10)
        }
    }
    
    private func configureSeparatorView() {
        guard let visualEffectView: NSVisualEffectView = visualEffectView else {
            return
        }
        let separatorView: NSView = .init()
        self.separatorView = separatorView
        separatorView.wantsLayer = true
        separatorView.layer?.backgroundColor = NSColor.white.withAlphaComponent(0.2).cgColor
        separatorView.translatesAutoresizingMaskIntoConstraints = false
        visualEffectView.addSubview(separatorView)
        separatorView.snp.remakeConstraints { [weak searchField] make in
            guard let searchField: NSSearchField = searchField else {
                return
            }
            make.top.equalTo(searchField.snp.bottom).offset(10)
            make.leading.equalToSuperview()
            make.trailing.equalToSuperview()
            make.height.equalTo(1)
        }
    }
    
    private func configureTableView() {
        guard let visualEffectView: NSVisualEffectView = visualEffectView else {
            return
        }
        let tableView: NSTableView = .init()
        self.tableView = tableView
        tableView.style = .sourceList
        tableView.wantsLayer = true
        tableView.layer?.backgroundColor = .clear
        tableView.dataSource = self
        tableView.delegate = self
        
        if tableView.headerView == nil {
            tableView.headerView = .init()
        }
        
        if let headerView: NSTableHeaderView = tableView.headerView {
            let clickGesture: NSClickGestureRecognizer = .init(target: self, action: #selector(clickedHeaderView(_:)))
            headerView.addGestureRecognizer(clickGesture)
        }
        
        let searchIdentifier: NSUserInterfaceItemIdentifier = .init(SearchTableCellView.className)
        self.searchIdentifier = searchIdentifier
        let searchColumn: NSTableColumn = .init(identifier: searchIdentifier)
        self.searchColumn = searchColumn
        searchColumn.title = ""
        tableView.addTableColumn(searchColumn)
        tableView.register(NSNib(nibNamed: SearchTableCellView.className, bundle: .main), forIdentifier: searchIdentifier)
        
        
        let scrollView: NSScrollView = .init()
        scrollView.documentView = tableView
        scrollView.autohidesScrollers = true
        scrollView.hasVerticalScroller = true
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        visualEffectView.addSubview(scrollView)
        scrollView.snp.remakeConstraints { [weak separatorView] make in
            guard let separatorView: NSView = separatorView else {
                return
            }
            make.top.equalTo(separatorView.snp.bottom)
            make.leading.equalToSuperview()
            make.trailing.equalToSuperview()
            make.bottom.equalToSuperview()
        }
    }
    
    private func configureViewModel() {
        let viewModel: SearchViewModel = .init()
        self.viewModel = viewModel
    }
    
    private func bind() {
        viewModel?.addrLinkJusoDataEvent
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] (_, text) in
                self?.tableView?.reloadData()
                self?.updateColumnTitle(for: text)
                self?.tableView?.scrollToTop()
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
    }
    
    private func updateColumnTitle(for text: String) {
        searchColumn?.title = String(format: Localizable.RESULTS_FOR_ADDRESS.string, text)
    }
    
    @objc private func clickedHeaderView(_ sender: NSClickGestureRecognizer) {
        tableView?.scrollToTop()
    }
}

extension SearchViewController: NSTableViewDataSource {
    internal func numberOfRows(in tableView: NSTableView) -> Int {
        guard let viewModel: SearchViewModel = viewModel else {
            return 0
        }
        return viewModel.addrLinkJusoData.count
    }
    
    internal func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        guard let viewModel: SearchViewModel = viewModel,
              let searchIdentifier: NSUserInterfaceItemIdentifier = searchIdentifier,
              let cell: SearchTableCellView = tableView.makeView(withIdentifier: searchIdentifier, owner: self) as? SearchTableCellView
        else {
            return nil
        }

        cell.textLabel.stringValue = viewModel.addrLinkJusoData[row].roadAddr

        return cell
    }
}

extension SearchViewController: NSTableViewDelegate {
    internal func tableView(_ tableView: NSTableView, heightOfRow row: Int) -> CGFloat {
        return 40
    }
}

extension SearchViewController: NSSearchFieldDelegate {
    internal func controlTextDidEndEditing(_ obj: Notification) {
        guard let searchField: NSSearchField = obj.object as? NSSearchField,
              let movement: NSNumber = obj.userInfo?["NSTextMovement"] as? NSNumber,
              (!searchField.stringValue.isEmpty && movement.intValue == NSReturnTextMovement) else {
            return
        }
        
        showSpinnerView()
        viewModel?.searchEvent = searchField.stringValue
    }
}
