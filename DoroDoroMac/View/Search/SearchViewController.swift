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
    private weak var searchField: UndoableSearchField? = nil
    private weak var searchFieldTopConstraint: Constraint? = nil
    private weak var separatorView: NSView? = nil
    private weak var tableView: CopyableTableView? = nil
    private weak var clipView: NSClipView? = nil
    private weak var scrollView: NSScrollView? = nil
    private var searchIdentifier: NSUserInterfaceItemIdentifier? = nil
    private weak var searchColumn: NSTableColumn? = nil
    private weak var guideContainerView: NSView? = nil
    private weak var guideTextField: NSTextField? = nil
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
        configureGuideTextField()
        configureMenu()
        toggleGuideContainerViewHiddenStatus(false)
        configureViewModel()
        bind()
    }
    
    internal override func viewDidLayout() {
        super.viewDidLayout()
        searchFieldTopConstraint?.update(offset: searchWindow?.topBarHeight ?? 28)
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
        
        let searchField: UndoableSearchField = .init()
        self.searchField = searchField
        searchField.delegate = self
        searchField.translatesAutoresizingMaskIntoConstraints = false
        visualEffectView.addSubview(searchField)
        searchField.snp.remakeConstraints { [weak self] make in
            let top: ConstraintMakerEditable = make.top.equalToSuperview().offset(28)
            self?.searchFieldTopConstraint = top.constraint
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
        guard let visualEffectView: NSVisualEffectView = visualEffectView,
              let separatorView: NSView = separatorView else {
            return
        }
        let tableView: CopyableTableView = .init()
        self.tableView = tableView
        tableView.style = .sourceList
        tableView.wantsLayer = true
        tableView.layer?.backgroundColor = .clear
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
    
    private func configureGuideTextField() {
        guard let visualEffectView: NSVisualEffectView = visualEffectView,
              let separatorView: NSView = separatorView else {
            return
        }
        
        let guideContainerView: NSView = .init()
        self.guideContainerView = guideContainerView
        guideContainerView.translatesAutoresizingMaskIntoConstraints = false
        visualEffectView.addSubview(guideContainerView)
        guideContainerView.snp.remakeConstraints { [weak separatorView] make in
            guard let separatorView: NSView = separatorView else {
                return
            }
            make.top.equalTo(separatorView.snp.bottom)
            make.leading.equalToSuperview()
            make.trailing.equalToSuperview()
            make.bottom.equalToSuperview()
        }
        
        let guideTextField: NSTextField = .init(wrappingLabelWithString: Localizable.SEARCH_GUIDE_LABEL.string)
        self.guideTextField = guideTextField
        guideTextField.translatesAutoresizingMaskIntoConstraints = false
        guideContainerView.addSubview(guideTextField)
        guideTextField.snp.remakeConstraints { make in
            make.centerY.equalToSuperview()
            make.leading.equalToSuperview().offset(20)
            make.trailing.equalToSuperview().offset(-20)
        }
        guideTextField.setLabelStyle()
        guideTextField.alignment = .center
    }
    
    private func configureMenu() {
        let menu: NSMenu = .init()
        menu.delegate = self
        tableView?.menu = menu
    }
    
    private func configureViewModel() {
        let viewModel: SearchViewModel = .init()
        self.viewModel = viewModel
        viewModel.dataSource = makeDataSource()
    }
    
    private func bind() {
        viewModel?.refreshedEvent
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] (text, hasData, isFirstPage) in
                self?.updateColumnTitle(for: text)
                self?.toggleGuideContainerViewHiddenStatus(hasData)
                
                if isFirstPage {
                    self?.tableView?.scrollToTop()
                    
                    // headerView reload 용도
                    self?.tableView?.reloadData()
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
        
        BookmarksService.shared.dataEvent
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] _ in
                self?.updateBookmarkMenuItem()
            })
            .store(in: &cancellableBag)
        
//        if let clipView: NSClipView = clipView {
//            NotificationCenter.default
//                .publisher(for: NSView.boundsDidChangeNotification, object: clipView)
//                .throttle(for: .seconds(1), scheduler: DispatchQueue.global(qos: .userInteractive), latest: false)
//                .receive(on: DispatchQueue.main)
//                .sink(receiveValue: { [weak self] notification in
//                    guard let bounds: CGRect = (notification.object as? NSClipView)?.bounds else {
//                        return
//                    }
//                    self?.determineLoadNextPage(bounds: bounds)
//                })
//                .store(in: &cancellableBag)
//        }
        
        // 스크롤이 끝났을 때만 다음 페이지를 불러온다
        if let scrollView: NSScrollView = scrollView {
            NotificationCenter.default
                .publisher(for: NSScrollView.didEndLiveScrollNotification, object: scrollView)
                .sink(receiveValue: { [weak self] _ in
                    guard let bounds: CGRect = self?.clipView?.bounds else {
                        return
                    }
                    self?.determineLoadNextPage(bounds: bounds)
                })
                .store(in: &cancellableBag)
        }
        
        if let searchWindow: SearchWindow = searchWindow {
            searchWindow.resizeEvent
                .debounce(for: 0.05, scheduler: DispatchQueue.global(qos: .userInteractive))
                .receive(on: DispatchQueue.main)
                .sink(receiveValue: { [weak self] rect in
                    self?.tableView?.reloadData()
                })
                .store(in: &cancellableBag)

            NotificationCenter.default
                .publisher(for: NSWindow.didBecomeMainNotification, object: searchWindow)
                .receive(on: DispatchQueue.main)
                .sink(receiveValue: { [weak self] _ in
                    self?.updateBookmarkMenuItem()
                })
                .store(in: &cancellableBag)
            
            // cancellableBag 때문에 생기는 searchWindow 간의 순환참조 문제를 없애준다.
            NotificationCenter.default
                .publisher(for: NSWindow.willCloseNotification, object: searchWindow)
                .receive(on: DispatchQueue.main)
                .sink(receiveValue: { [weak self] _ in
                    // Combine의 경우 NotificationCenter의 Object를 Strong으로 붙잡는다. 따라서 직접 비워줘야 한다.
                    self?.cancellableBag.removeAll()
                    
//                    if let clipView: NSClipView = self?.clipView {
//                        NotificationCenter.default.removeObserver(clipView)
//                    }
                    if let scrollView: NSScrollView = self?.scrollView {
                        NotificationCenter.default.removeObserver(scrollView)
                    }
                })
                .store(in: &cancellableBag)
        }
        
        if let tableView: CopyableTableView = tableView {
            tableView.copyEvent
                .receive(on: DispatchQueue.main)
                .sink(receiveValue: { [weak self] sender in
                    self?.copyRoadAddr(sender)
                })
                .store(in: &cancellableBag)
        }
    }
    
    private func makeDataSource() -> SearchViewModel.DataSource {
        guard let tableView: CopyableTableView = tableView else {
            fatalError("TableView does not exists!")
        }
        
        let dataSource: SearchViewModel.DataSource = .init(tableView: tableView) { [weak self] (tableView, column, row, item) in
            guard let self = self,
                  let item: SearchResultItem = item as? SearchResultItem
                  else { return .init() }
            return self.getTableViewCellView(tableView, viewFor: column, row: row, item: item)
        }
        
        return dataSource
    }
    
    private func updateBookmarkMenuItem() {
        guard let customMenu: CustomMenu = NSApp.mainMenu as? CustomMenu else {
            return
        }
        
        guard let (_, selectedMenuJusoData): (Int, AddrLinkJusoData) = getSelectedItem() else {
            customMenu.updateBookmarkMenuItem(target: nil, action: nil, bookmarked: false)
            return
        }
        
        let roadAddr: String = selectedMenuJusoData.roadAddr
        let bookmarked: Bool = BookmarksService.shared.isBookmarked(roadAddr)
        
        customMenu.updateBookmarkMenuItem(target: self, action: #selector(toggleBookmarks(_:)), bookmarked: bookmarked)
    }
    
    private func updateColumnTitle(for text: String) {
        searchColumn?.title = String(format: Localizable.RESULTS_FOR_ADDRESS.string, text)
    }
    
    @objc private func clickedHeaderView(_ sender: NSClickGestureRecognizer) {
        tableView?.scrollToTop()
    }
    
    private func toggleGuideContainerViewHiddenStatus(_ hidden: Bool) {
        guideContainerView?.isHidden = hidden
        scrollView?.isHidden = !hidden
    }
    
    private func determineLoadNextPage(bounds: CGRect) {
        let maxPoint: CGPoint = .init(x: bounds.origin.x, y: bounds.maxY)
        
        guard let currentRow: Int = tableView?.row(at: maxPoint) else {
            return
        }
        
        guard let viewModel: SearchViewModel = viewModel,
              let countOfResultItems: Int = viewModel.getResultItems()?.count else {
            return
        }
        
        if currentRow == -1 || (currentRow + 1) == countOfResultItems {
            let requested: Bool = viewModel.requestNextPageIfAvailable()
            if requested {
                showSpinnerView()
            }
        }
    }
    
    @objc private func removeFromBookmarks(_ sender: NSMenuItem) {
        guard let (_, selectedMenuJusoData): (Int, AddrLinkJusoData) = getAnyItem() else {
            return
        }
        BookmarksService.shared.removeBookmark(selectedMenuJusoData.roadAddr)
    }
    
    @objc private func addToBookmarks(_ sender: NSMenuItem) {
        guard let (_, selectedMenuJusoData): (Int, AddrLinkJusoData) = getAnyItem() else {
            return
        }
        BookmarksService.shared.addBookmark(selectedMenuJusoData.roadAddr)
    }
    
    @objc private func copyRoadAddr(_ sender: NSMenuItem) {
        guard let (_, selectedMenuJusoData): (Int, AddrLinkJusoData) = getAnyItem() else {
            return
        }
        NSPasteboard.general.declareTypes([.string], owner: nil)
        NSPasteboard.general.setString(selectedMenuJusoData.roadAddr, forType: .string)
    }
    
    @objc private func shareRoadAddr(_ sender: NSMenuItem) {
        guard let (clickedRow, selectedMenuJusoData): (Int, AddrLinkJusoData) = getAnyItem(),
              let cell: NSView = tableView?.rowView(atRow: clickedRow, makeIfNecessary: false) else {
            return
        }
        
        let picker: NSSharingServicePicker = .init(items: [selectedMenuJusoData.roadAddr])
        picker.show(relativeTo: .zero, of: cell, preferredEdge: .minY)
    }
    
    @objc private func toggleBookmarks(_ sender: NSMenuItem) {
        guard let (_, selectedMenuJusoData): (Int, AddrLinkJusoData) = getAnyItem() else {
            return
        }
        BookmarksService.shared.toggleBookmark(selectedMenuJusoData.roadAddr)
    }
    
    private func presentDetailVC(data: AddrLinkJusoData, from view: NSView) {
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
    
    //
    
    private func getSelectedItem() -> (selectedRow: Int, selectedMenuJusoData: AddrLinkJusoData)? {
        guard let viewModel: SearchViewModel = viewModel,
              let selectedRow: Int = tableView?.selectedRow,
              let resultItem: SearchResultItem = viewModel.getResultItem(row: selectedRow),
              let linkJusoData: AddrLinkJusoData = resultItem.linkJusoData,
              (selectedRow >= 0)
        else { return nil }
        
        return (selectedRow: selectedRow, selectedMenuJusoData: linkJusoData)
    }
    
    private func getClickedItem() -> (clickedRow: Int, selectedMenuJusoData: AddrLinkJusoData)? {
        guard let viewModel: SearchViewModel = viewModel,
              let clickedRow: Int = tableView?.clickedRow,
              let resultItem: SearchResultItem = viewModel.getResultItem(row: clickedRow),
              let linkJusoData: AddrLinkJusoData = resultItem.linkJusoData,
              (clickedRow >= 0)
        else { return nil }
        
        return (clickedRow: clickedRow, selectedMenuJusoData: linkJusoData)
    }
    
    private func getAnyItem() -> (row: Int, selectedMenuJusoData: AddrLinkJusoData)? {
        var item: (Int, AddrLinkJusoData)? = getClickedItem()
        if item == nil {
            item = getSelectedItem()
        }
        return item
    }
    
    private func getTableViewCellView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int, item: SearchResultItem) -> NSView {
        guard let searchIdentifier: NSUserInterfaceItemIdentifier = searchIdentifier,
              let cell: SimgleResultTableCellView = tableView.makeView(withIdentifier: searchIdentifier, owner: self) as? SimgleResultTableCellView
        else {
            return .init()
        }
        
        guard let resultItem: SearchResultItem = viewModel?.getResultItem(row: row),
              let linkJusoData: AddrLinkJusoData = resultItem.linkJusoData else {
            return .init()
        }
        
        cell.configure(text: linkJusoData.roadAddr,
                       width: view.bounds.width)
        cell.chageUIWhenActiveAppStatusChanged = true
        return cell
    }
}

extension SearchViewController: NSTableViewDelegate {
    internal func tableViewSelectionDidChange(_ notification: Notification) {
        guard let (selectedRow, selectedMenuJusoData): (Int, AddrLinkJusoData) = getSelectedItem() else {
            return
        }
        
        guard let tableView: NSTableView = tableView,
              let cell: NSView = tableView.rowView(atRow: selectedRow, makeIfNecessary: false) else {
            return
        }
        
        updateBookmarkMenuItem()
        presentDetailVC(data: selectedMenuJusoData, from: cell)
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
        guard let (_, selectedMenuJusoData): (Int, AddrLinkJusoData) = getAnyItem() else {
            return
        }
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

extension SearchViewController: NSMenuItemValidation {
    internal func validateMenuItem(_ menuItem: NSMenuItem) -> Bool {
        // https://stackoverflow.com/a/15184735
        return (getAnyItem() != nil)
    }
}
