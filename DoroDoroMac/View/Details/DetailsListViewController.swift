//
//  DetailsListViewController.swift
//  DoroDoroMac
//
//  Created by Jinwoo Kim on 3/20/21.
//

import Cocoa
import Combine
import SnapKit

internal final class DetailsListViewController: NSViewController {
    internal var dataSource: [DetailsListResultItem] = [] {
        didSet {
            tableView?.reloadData()
        }
    }
    
    private weak var tableView: CopyableTableView? = nil
    private var listIdentifier: NSUserInterfaceItemIdentifier? = nil
    private var cancellableBag: Set<AnyCancellable> = .init()
    
    internal override func loadView() {
        let view: NSView = .init()
        self.view = view
    }
    
    internal override func viewDidLoad() {
        super.viewDidLoad()
        configureTableView()
        configureMenu()
        bind()
    }
    
    private func configureTableView() {
        let tableView: CopyableTableView = .init()
        self.tableView = tableView
        tableView.style = .plain
        tableView.wantsLayer = true
        tableView.layer?.backgroundColor = .clear
        tableView.backgroundColor = .clear
        tableView.dataSource = self
        tableView.delegate = self
        tableView.headerView = nil
        tableView.usesAutomaticRowHeights = true
        
        let listIdentifier: NSUserInterfaceItemIdentifier = .init(DetailTableCellView.className)
        self.listIdentifier = listIdentifier
        let listColumn: NSTableColumn = .init(identifier: listIdentifier)
//        listColumn.minWidth = 400
        listColumn.title = ""
        tableView.addTableColumn(listColumn)
        tableView.register(NSNib(nibNamed: DetailTableCellView.className, bundle: .main), forIdentifier: listIdentifier)
        
        let clipView: NSClipView = .init()
        clipView.documentView = tableView

        let scrollView: NSScrollView = .init()
        scrollView.contentView = clipView
        scrollView.autohidesScrollers = true
        scrollView.hasVerticalScroller = true
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(scrollView)
        scrollView.snp.remakeConstraints { $0.edges.equalToSuperview() }
        // scrollView도 투명하게 하기 위해
        scrollView.drawsBackground = false
    }
    
    private func configureMenu() {
        let menu: NSMenu = .init()
        menu.delegate = self
        tableView?.menu = menu
    }
    
    private func bind() {
        if let tableView: CopyableTableView = tableView {
            tableView.copyEvent
                .receive(on: DispatchQueue.main)
                .sink(receiveValue: { [weak self] sender in
                    self?.copyRoadAddr(sender)
                })
                .store(in: &cancellableBag)
        }
    }
    
    @objc private func copyRoadAddr(_ sender: NSMenuItem) {
        guard let (_, selectedString): (Int, String) = getAnyItem() else {
            return
        }
        NSPasteboard.general.declareTypes([.string], owner: nil)
        NSPasteboard.general.setString(selectedString, forType: .string)
    }
    
    @objc private func shareRoadAddr(_ sender: NSMenuItem) {
        guard let (clickedRow, selectedString): (Int, String) = getAnyItem() else {
            return
        }
        guard let cell: NSView = tableView?.rowView(atRow: clickedRow, makeIfNecessary: false) else {
            return
        }
        
        let picker: NSSharingServicePicker = .init(items: [selectedString])
        picker.show(relativeTo: .zero, of: cell, preferredEdge: .minY)
    }
    
    //
    
    private func getSelectedItem() -> (selectedRow: Int, selectedString: String)? {
        guard let selectedRow: Int = tableView?.selectedRow,
              (selectedRow >= 0) && (dataSource.count > selectedRow)
        else { return nil }
        
        return (selectedRow: selectedRow, selectedString: dataSource[selectedRow].secondaryText)
    }
    
    private func getClickedItem() -> (clickedRow: Int, selectedString: String)? {
        guard let clickedRow: Int = tableView?.clickedRow,
              (clickedRow >= 0) && (dataSource.count > clickedRow)
        else { return nil }
        
        return (clickedRow: clickedRow, selectedString: dataSource[clickedRow].secondaryText)
    }
    
    private func getAnyItem() -> (row: Int, selectedString: String)? {
        var item: (Int, String)? = getClickedItem()
        if item == nil {
            item = getSelectedItem()
        }
        return item
    }
}

extension DetailsListViewController: NSTableViewDataSource {
    internal func numberOfRows(in tableView: NSTableView) -> Int {
        return dataSource.count
    }
    
    internal func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        guard let listIdentifier: NSUserInterfaceItemIdentifier = listIdentifier,
              let cell: DetailTableCellView = tableView.makeView(withIdentifier: listIdentifier, owner: self) as? DetailTableCellView
        else {
            return nil
        }
        
        guard dataSource.count > row else {
            return nil
        }
        
        cell.configure(mainText: dataSource[row].text,
                       subText: dataSource[row].secondaryText,
                       width: view.bounds.width)
        
        return cell
    }
}

extension DetailsListViewController: NSTableViewDelegate {
}

extension DetailsListViewController: NSMenuDelegate {
    internal func menuWillOpen(_ menu: NSMenu) {
        guard let (_, selectedString): (Int, String) = getClickedItem() else {
            return
        }
        
        menu.items.removeAll()
        
        guard selectedString != Localizable.NO_DATA.string else {
            return
        }
        
        menu.addItem(NSMenuItem(title: Localizable.COPY.string,
                                action: #selector(copyRoadAddr(_:)),
                                keyEquivalent: ""))
        menu.addItem(NSMenuItem(title: Localizable.SHARE.string,
                                action: #selector(shareRoadAddr(_:)),
                                keyEquivalent: ""))
    }
}
