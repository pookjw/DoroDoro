//
//  BookmarksViewController.swift
//  DoroDoroMac
//
//  Created by Jinwoo Kim on 3/22/21.
//

import Cocoa
import Combine
import SnapKit
import DoroDoroMacAPI

internal final class BookmarksViewController: NSViewController {
    internal weak var popover: NSPopover? = nil
    private weak var searchField: UndoableSearchField? = nil
    private weak var separatorView: NSView? = nil
    private weak var tableView: CopyableTableView? = nil
    private weak var scrollView: NSScrollView? = nil
    private var bookmarksIdentifier: NSUserInterfaceItemIdentifier? = nil
    private weak var guideContainerView: NSView? = nil
    private weak var guideTextField: NSTextField? = nil
    private var viewModel: BookmarksViewModel? = nil
    private var cancellableBag: Set<AnyCancellable> = .init()
    
    internal override func loadView() {
        let view: NSView = .init()
        self.view = view
    }

    internal override func viewDidLoad() {
        super.viewDidLoad()
        configureSearchField()
        configureSeparatorView()
        configureTableView()
        configureGuideTextField()
        configureMenu()
        toggleGuideContainerViewHiddenStatus(false)
        configureViewModel()
        bind()
    }
    
    private func configureSearchField() {
        let searchField: UndoableSearchField = .init()
        self.searchField = searchField
        searchField.delegate = self
        searchField.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(searchField)
        searchField.snp.remakeConstraints { make in
            make.top.equalToSuperview().offset(10)
            make.leading.equalToSuperview().offset(10)
            make.trailing.equalToSuperview().offset(-10)
        }
    }
    
    private func configureSeparatorView() {
        let separatorView: NSView = .init()
        self.separatorView = separatorView
        separatorView.wantsLayer = true
        separatorView.layer?.backgroundColor = NSColor.white.withAlphaComponent(0.2).cgColor
        separatorView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(separatorView)
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
        let tableView: CopyableTableView = .init()
        self.tableView = tableView
        tableView.style = .sourceList
        tableView.wantsLayer = true
        tableView.layer?.backgroundColor = .clear
        tableView.dataSource = self
        tableView.delegate = self
        tableView.usesAutomaticRowHeights = true
        tableView.headerView = nil
        
        let bookmarksIdentifier: NSUserInterfaceItemIdentifier = .init(SimgleResultTableCellView.className)
        self.bookmarksIdentifier = bookmarksIdentifier
        let bookmarksColumn: NSTableColumn = .init(identifier: bookmarksIdentifier)
        bookmarksColumn.title = ""
        tableView.addTableColumn(bookmarksColumn)
        tableView.register(NSNib(nibNamed: SimgleResultTableCellView.className, bundle: .main), forIdentifier: bookmarksIdentifier)
        
        let clipView: NSClipView = .init()
        clipView.documentView = tableView
        clipView.postsBoundsChangedNotifications = true

        let scrollView: NSScrollView = .init()
        self.scrollView = scrollView
        scrollView.contentView = clipView
        scrollView.autohidesScrollers = true
        scrollView.hasVerticalScroller = true
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(scrollView)
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
        guard let separatorView: NSView = separatorView else {
            return
        }
        
        let guideContainerView: NSView = .init()
        self.guideContainerView = guideContainerView
        guideContainerView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(guideContainerView)
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
        updateGuideLabelText(state: .noBookmarks)
    }
    
    private func configureMenu() {
        let menu: NSMenu = .init()
        menu.delegate = self
        tableView?.menu = menu
    }
    
    private func configureViewModel() {
        let viewModel: BookmarksViewModel = .init()
        self.viewModel = viewModel
    }
    
    private func bind() {
        viewModel?.refreshedEvent
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] (_, hasData, hasResult) in
                self?.tableView?.reloadData()
                self?.toggleGuideContainerViewHiddenStatus(hasData)
                
                if let hasResult: Bool = hasResult, !hasResult {
                    self?.updateGuideLabelText(state: .noSearchResults)
                } else {
                    self?.updateGuideLabelText(state: .noBookmarks)
                }
            })
            .store(in: &cancellableBag)
        
        if let popover: NSPopover = popover {
            NotificationCenter.default
                .publisher(for: NSPopover.didShowNotification, object: popover)
                .receive(on: DispatchQueue.main)
                .sink(receiveValue: { [weak self] _ in
                    self?.updateBookmarkMenuItem()
                })
                .store(in: &cancellableBag)
            
            NotificationCenter.default
                .publisher(for: NSPopover.didCloseNotification, object: popover)
                .receive(on: DispatchQueue.main)
                .sink(receiveValue: { [weak self] _ in
                    self?.cancellableBag.removeAll()
                    
                    if let popover: NSPopover = self?.popover {
                        NotificationCenter.default.removeObserver(popover)
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
    
    private func updateBookmarkMenuItem() {
        guard let customMenu: CustomMenu = NSApp.mainMenu as? CustomMenu else {
            return
        }
        
        guard let (_, selectedString): (Int, String) = getSelectedItem() else {
            customMenu.updateBookmarkMenuItem(target: nil, action: nil, bookmarked: false)
            return
        }
        
        let bookmarked: Bool = BookmarksService.shared.isBookmarked(selectedString)
        
        customMenu.updateBookmarkMenuItem(target: self, action: #selector(toggleBookmarks(_:)), bookmarked: bookmarked)
    }
    
    private func presentDetailVC(roadAddr: String, at view: NSView) {
        let popover: NSPopover = .init()
        let vc: DetailsViewController = .init()
        vc.loadViewIfNeeded()
        vc.setRoadAddr(roadAddr)
        vc.preferredContentSize = .init(width: 450, height: 600)
        popover.contentViewController = vc
        popover.behavior = .semitransient
        popover.show(relativeTo: view.bounds,
                     of: view,
                     preferredEdge: .maxX)
    }
    
    private func updateGuideLabelText(state: BookmarksGuideLabelTextState) {
        switch state {
        case .noBookmarks:
            guideTextField?.stringValue = Localizable.BOOKMARK_GUIDE_LABEL.string
        case .noSearchResults:
            guideTextField?.stringValue = Localizable.NO_SEARCH_RESULTS.string
        }
    }
    
    private func toggleGuideContainerViewHiddenStatus(_ hidden: Bool) {
        guideContainerView?.isHidden = hidden
        scrollView?.isHidden = !hidden
    }
    
    @objc private func removeFromBookmarks(_ sender: NSMenuItem) {
        guard let (_, selectedMenuRoadAddr): (Int, String) = getAnyItem() else {
            return
        }
        BookmarksService.shared.removeBookmark(selectedMenuRoadAddr)
    }
    
    @objc private func addToBookmarks(_ sender: NSMenuItem) {
        guard let (_, selectedMenuRoadAddr): (Int, String) = getAnyItem() else {
            return
        }
        BookmarksService.shared.addBookmark(selectedMenuRoadAddr)
    }
    
    @objc private func toggleBookmarks(_ sender: NSMenuItem) {
        guard let (_, selectedMenuRoadAddr): (Int, String) = getAnyItem() else {
            return
        }
        BookmarksService.shared.toggleBookmark(selectedMenuRoadAddr)
    }
    
    @objc private func copyRoadAddr(_ sender: NSMenuItem) {
        guard let (_, selectedMenuRoadAddr): (Int, String) = getAnyItem() else {
            return
        }
        NSPasteboard.general.declareTypes([.string], owner: nil)
        NSPasteboard.general.setString(selectedMenuRoadAddr, forType: .string)
    }
    
    @objc private func shareRoadAddr(_ sender: NSMenuItem) {
        guard let (row, selectedMenuRoadAddr): (Int, String) = getAnyItem(),
              let cell: NSView = tableView?.rowView(atRow: row, makeIfNecessary: false) else {
            return
        }
        
        let picker: NSSharingServicePicker = .init(items: [selectedMenuRoadAddr])
        picker.show(relativeTo: .zero, of: cell, preferredEdge: .minY)
    }
    
    private func getSelectedItem() -> (selectedRow: Int, selectedString: String)? {
        guard let viewModel: BookmarksViewModel = viewModel,
            let selectedRow: Int = tableView?.selectedRow,
            (selectedRow >= 0) && (viewModel.bookmarksData.count > selectedRow)
        else { return nil }
        
        return (selectedRow: selectedRow, selectedString: viewModel.bookmarksData[selectedRow])
    }
    
    private func getClickedItem() -> (clickedRow: Int, selectedString: String)? {
        guard let viewModel: BookmarksViewModel = viewModel,
            let clickedRow: Int = tableView?.clickedRow,
              (clickedRow >= 0) && (viewModel.bookmarksData.count > clickedRow)
        else { return nil }
        
        return (clickedRow: clickedRow, selectedString: viewModel.bookmarksData[clickedRow])
    }
    
    private func getAnyItem() -> (row: Int, selectedString: String)? {
        var item: (Int, String)? = getClickedItem()
        if item == nil {
            item = getSelectedItem()
        }
        return item
    }
}

extension BookmarksViewController: NSTableViewDataSource {
    internal func numberOfRows(in tableView: NSTableView) -> Int {
        guard let viewModel: BookmarksViewModel = viewModel else {
            return 0
        }
        return viewModel.bookmarksData.count
    }
    
    internal func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        guard let viewModel: BookmarksViewModel = viewModel,
              let bookmarksIdentifier: NSUserInterfaceItemIdentifier = bookmarksIdentifier,
              let cell: SimgleResultTableCellView = tableView.makeView(withIdentifier: bookmarksIdentifier, owner: self) as? SimgleResultTableCellView
        else {
            return nil
        }
        
        guard viewModel.bookmarksData.count > row else {
            return nil
        }
        
        cell.configure(text: viewModel.bookmarksData[row],
                       width: view.bounds.width)
        
        return cell
    }
}

extension BookmarksViewController: NSTableViewDelegate {
    internal func tableViewSelectionDidChange(_ notification: Notification) {
        guard let viewModel: BookmarksViewModel = viewModel,
              let clickedRow: Int = tableView?.selectedRow,
              clickedRow >= 0 &&
                viewModel.bookmarksData.count > clickedRow else {
            return
        }
        
        guard let tableView: NSTableView = notification.object as? NSTableView,
              let cell: NSView = tableView.rowView(atRow: clickedRow, makeIfNecessary: false) else {
            return
        }
        
        updateBookmarkMenuItem()
        let selectedMenuRoadAddr: String = viewModel.bookmarksData[clickedRow]
        presentDetailVC(roadAddr: selectedMenuRoadAddr, at: cell)
    }
}

extension BookmarksViewController: NSSearchFieldDelegate {
    internal func controlTextDidChange(_ obj: Notification) {
        guard let searchField: NSSearchField = obj.object as? NSSearchField else {
            return
        }
        viewModel?.searchEvent = searchField.stringValue
    }
}

extension BookmarksViewController: NSMenuDelegate {
    internal func menuWillOpen(_ menu: NSMenu) {
        guard let (_, selectedMenuRoadAddr): (Int, String) = getAnyItem() else {
            return
        }
        
        menu.items.removeAll()
        
        if BookmarksService.shared.isBookmarked(selectedMenuRoadAddr) {
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

extension BookmarksViewController: NSMenuItemValidation {
    internal func validateMenuItem(_ menuItem: NSMenuItem) -> Bool {
        // https://stackoverflow.com/a/15184735
        return (getAnyItem() != nil)
    }
}
