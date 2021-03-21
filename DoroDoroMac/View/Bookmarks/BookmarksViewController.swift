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
    private weak var searchField: NSSearchField? = nil
    private weak var separatorView: NSView? = nil
    private weak var tableView: NSTableView? = nil
    private var bookmarksIdentifier: NSUserInterfaceItemIdentifier? = nil
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
        configureViewModel()
        bind()
    }
    
    private func configureSearchField() {
        let searchField: NSSearchField = .init()
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
        let tableView: NSTableView = .init()
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
    
    private func configureViewModel() {
        let viewModel: BookmarksViewModel = .init()
        self.viewModel = viewModel
    }
    
    private func bind() {
        viewModel?.bookmarksDataEvent
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] _ in
                self?.tableView?.reloadData()
            })
            .store(in: &cancellableBag)
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
    
}

extension BookmarksViewController: NSSearchFieldDelegate {
    internal func controlTextDidChange(_ obj: Notification) {
        guard let searchField: NSSearchField = obj.object as? NSSearchField else {
            return
        }
        viewModel?.searchEvent = searchField.stringValue
    }
}
