//
//  DetailsListViewController.swift
//  DoroDoroMac
//
//  Created by Jinwoo Kim on 3/20/21.
//

import Cocoa
import SnapKit

internal final class DetailsListViewController: NSViewController {
    internal var dataSource: [DetailsListResultItem] = [] {
        didSet {
            tableView?.reloadData()
        }
    }
    
    private weak var tableView: NSTableView? = nil
    private var listIdentifier: NSUserInterfaceItemIdentifier? = nil
    
    internal override func loadView() {
        let view: NSView = .init()
        self.view = view
    }
    
    internal override func viewDidLoad() {
        super.viewDidLoad()
        configureTableView()
    }
    
    private func configureTableView() {
        let tableView: NSTableView = .init()
        self.tableView = tableView
        tableView.style = .inset
        tableView.wantsLayer = true
        tableView.layer?.backgroundColor = .clear
        tableView.dataSource = self
        tableView.delegate = self
        tableView.headerView = nil
        tableView.usesAutomaticRowHeights = true
        
        let listIdentifier: NSUserInterfaceItemIdentifier = .init(DetailsTableCellView.className)
        self.listIdentifier = listIdentifier
        let listColumn: NSTableColumn = .init(identifier: listIdentifier)
//        listColumn.minWidth = 400
        listColumn.title = ""
        tableView.addTableColumn(listColumn)
        tableView.register(NSNib(nibNamed: DetailsTableCellView.className, bundle: .main), forIdentifier: listIdentifier)
        
        let clipView: NSClipView = .init()
        clipView.documentView = tableView

        let scrollView: NSScrollView = .init()
        scrollView.contentView = clipView
        scrollView.autohidesScrollers = true
        scrollView.hasVerticalScroller = true
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(scrollView)
        scrollView.snp.remakeConstraints { $0.edges.equalToSuperview() }
    }
}

extension DetailsListViewController: NSTableViewDataSource {
    internal func numberOfRows(in tableView: NSTableView) -> Int {
        return dataSource.count
    }
    
    internal func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        guard let listIdentifier: NSUserInterfaceItemIdentifier = listIdentifier,
              let cell: DetailsTableCellView = tableView.makeView(withIdentifier: listIdentifier, owner: self) as? DetailsTableCellView
        else {
            return nil
        }
        
        guard dataSource.count > row else {
            return nil
        }
        
        cell.configure(mainText: dataSource[row].text, subText: dataSource[row].secondaryText)
        
        return cell
    }
}

extension DetailsListViewController: NSTableViewDelegate {
//    internal func tableView(_ tableView: NSTableView, heightOfRow row: Int) -> CGFloat {
//        return 51
//    }
}
