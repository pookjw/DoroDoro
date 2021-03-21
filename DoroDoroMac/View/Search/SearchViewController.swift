//
//  SearchViewController.swift
//  DoroDoroMac
//
//  Created by Jinwoo Kim on 3/14/21.
//

import Cocoa
import Combine
import SnapKit
import DoroDoroMacAPI

internal final class SearchViewController: NSViewController {
    internal weak var searchWindow: SearchWindow? = nil
    private weak var visualEffectView: NSVisualEffectView? = nil
    private weak var searchField: NSSearchField? = nil
    private weak var separatorView: NSView? = nil
    private weak var tableView: NSTableView? = nil
    private weak var clipView: NSClipView? = nil
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
        configureMenu()
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
        tableView.usesAutomaticRowHeights = true
        
        if tableView.headerView == nil {
            tableView.headerView = .init()
        }
        
        if let headerView: NSTableHeaderView = tableView.headerView {
            let clickGesture: NSClickGestureRecognizer = .init(target: self, action: #selector(clickedHeaderView(_:)))
            headerView.addGestureRecognizer(clickGesture)
        }
        
        let searchIdentifier: NSUserInterfaceItemIdentifier = .init(SimgleResultTableCellView.className)
        self.searchIdentifier = searchIdentifier
        let searchColumn: NSTableColumn = .init(identifier: searchIdentifier)
        self.searchColumn = searchColumn
        searchColumn.title = ""
        tableView.addTableColumn(searchColumn)
        tableView.register(NSNib(nibNamed: SimgleResultTableCellView.className, bundle: .main), forIdentifier: searchIdentifier)
        
        // 그냥 tableView를 등록할 경우 bound 계산이 제대로 안 된다. 따라서 정석대로 NSClipView와 NSScrollView를 써준다.
        
        let clipView: NSClipView = .init()
        self.clipView = clipView
        clipView.documentView = tableView
        clipView.postsBoundsChangedNotifications = true

        let scrollView: NSScrollView = .init()
        self.scrollView = scrollView
        scrollView.contentView = clipView
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
    
    private func configureMenu() {
        let menu: NSMenu = .init()
        menu.delegate = self
        tableView?.menu = menu
    }
    
    private func configureViewModel() {
        let viewModel: SearchViewModel = .init()
        self.viewModel = viewModel
    }
    
    private func bind() {
        viewModel?.addrLinkJusoDataEvent
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] (_, text, isFirstPage) in
                self?.tableView?.reloadData()
                self?.updateColumnTitle(for: text)
                if isFirstPage {
                    self?.tableView?.scrollToTop()
                }
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
        
        if let clipView: NSClipView = clipView {
            NotificationCenter.default
                .publisher(for: NSView.boundsDidChangeNotification, object: clipView)
                .sink(receiveValue: { [weak self] notification in
                    guard let bounds: CGRect = (notification.object as? NSClipView)?.bounds else {
                        return
                    }
                    self?.determineLoadNextPage(bounds: bounds)
                })
                .store(in: &cancellableBag)
        }
        
        searchWindow?.resizeEvent
            .debounce(for: 0.05, scheduler: DispatchQueue.global(qos: .userInteractive))
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] rect in
                self?.tableView?.reloadData()
            })
            .store(in: &cancellableBag)
    }
    
    private func updateColumnTitle(for text: String) {
        searchColumn?.title = String(format: Localizable.RESULTS_FOR_ADDRESS.string, text)
    }
    
    @objc private func clickedHeaderView(_ sender: NSClickGestureRecognizer) {
        tableView?.scrollToTop()
    }
    
    private func determineLoadNextPage(bounds: CGRect) {
        guard let viewModel: SearchViewModel = viewModel else {
            return
        }
        
        let maxPoint: CGPoint = .init(x: bounds.origin.x, y: bounds.maxY)
        
        guard let currentRow: Int = tableView?.row(at: maxPoint) else {
            return
        }
        
        if currentRow == -1 || (currentRow + 1) == viewModel.addrLinkJusoData.count {
            let requested: Bool = viewModel.requestNextPageIfAvailable()
            if requested {
                showSpinnerView()
            }
        }
    }
    
    @objc private func removeFromBookmarks(_ sender: NSMenuItem) {
        guard let selectedMenuJusoData: AddrLinkJusoData = viewModel?.selectedMenuJusoData else {
            return
        }
        BookmarksService.shared.removeBookmark(selectedMenuJusoData.roadAddr)
    }
    
    @objc private func addToBookmarks(_ sender: NSMenuItem) {
        guard let selectedMenuJusoData: AddrLinkJusoData = viewModel?.selectedMenuJusoData else {
            return
        }
        BookmarksService.shared.addBookmark(selectedMenuJusoData.roadAddr)
    }
    
    @objc private func copyRoadAddr(_ sender: NSMenuItem) {
        guard let selectedMenuJusoData: AddrLinkJusoData = viewModel?.selectedMenuJusoData else {
            return
        }
        print(sender)
        NSPasteboard.general.declareTypes([.string], owner: nil)
        NSPasteboard.general.setString(selectedMenuJusoData.roadAddr, forType: .string)
    }
    
    @objc private func shareRoadAddr(_ sender: NSMenuItem) {
        guard let selectedMenuJusoData: AddrLinkJusoData = viewModel?.selectedMenuJusoData,
              let selectedMenuRow: Int = viewModel?.selectedMenuRow,
              let cell: NSView = tableView?.rowView(atRow: selectedMenuRow, makeIfNecessary: false) else {
            return
        }
        
        let picker: NSSharingServicePicker = .init(items: [selectedMenuJusoData.roadAddr])
        picker.show(relativeTo: .zero, of: cell, preferredEdge: .minY)
    }
    
    private func presentDetailVC(data: AddrLinkJusoData, at view: NSView) {
        let popover: NSPopover = .init()
        let vc: DetailsViewController = .init()
        vc.loadViewIfNeeded()
        vc.setLinkJusoData(data)
//        vc.setRoadAddr(data.roadAddr)
        vc.preferredContentSize = .init(width: 450, height: 600)
        popover.contentViewController = vc
        popover.behavior = .semitransient
        popover.show(relativeTo: view.bounds,
                     of: view,
                     preferredEdge: .maxX)
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
              let cell: SimgleResultTableCellView = tableView.makeView(withIdentifier: searchIdentifier, owner: self) as? SimgleResultTableCellView
        else {
            return nil
        }
        
        guard viewModel.addrLinkJusoData.count > row else {
            return nil
        }
        
        cell.configure(text: viewModel.addrLinkJusoData[row].roadAddr,
                       width: view.bounds.width)
        
        return cell
    }
}

extension SearchViewController: NSTableViewDelegate {
    internal func tableViewSelectionDidChange(_ notification: Notification) {
        guard let viewModel: SearchViewModel = viewModel,
              let clickedRow: Int = tableView?.selectedRow,
              clickedRow >= 0 &&
                viewModel.addrLinkJusoData.count > clickedRow else {
            return
        }
        
        guard let tableView: NSTableView = notification.object as? NSTableView,
              let cell: NSView = tableView.rowView(atRow: clickedRow, makeIfNecessary: false) else {
            return
        }
        
        let selectedMenuJusoData: AddrLinkJusoData = viewModel.addrLinkJusoData[clickedRow]
        presentDetailVC(data: selectedMenuJusoData, at: cell)
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

extension SearchViewController: NSMenuDelegate {
    internal func menuWillOpen(_ menu: NSMenu) {
        guard let viewModel: SearchViewModel = viewModel,
              let clickedRow: Int = tableView?.clickedRow,
              clickedRow >= 0 else {
            return
        }
        
        guard viewModel.addrLinkJusoData.count > clickedRow else {
            return
        }
        
        let selectedMenuJusoData: AddrLinkJusoData = viewModel.addrLinkJusoData[clickedRow]
        viewModel.selectedMenuJusoData = selectedMenuJusoData
        viewModel.selectedMenuRow = clickedRow
        let roadAddr: String = selectedMenuJusoData.roadAddr
        
        menu.items.removeAll()
        
        if BookmarksService.shared.isBookmarked(roadAddr) {
            menu.addItem(NSMenuItem(title: Localizable.REMOVE_FROM_BOOKMARKS.string,
                                    action: #selector(removeFromBookmarks(_:)),
                                    keyEquivalent: ""))
        } else {
            menu.addItem(NSMenuItem(title: Localizable.ADD_TO_BOOKMARKS.string,
                                    action: #selector(addToBookmarks(_:)),
                                    keyEquivalent: ""))
        }
        
        menu.addItem(NSMenuItem(title: Localizable.COPY.string,
                                action: #selector(copyRoadAddr(_:)),
                                keyEquivalent: ""))
        menu.addItem(NSMenuItem(title: Localizable.SHARE.string,
                                action: #selector(shareRoadAddr(_:)),
                                keyEquivalent: ""))
    }
}
