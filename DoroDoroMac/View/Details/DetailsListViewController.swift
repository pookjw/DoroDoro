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
    private var selectedString: String? = nil
    private var selectedMenuRow: Int? = nil
    
    internal override func loadView() {
        let view: NSView = .init()
        self.view = view
    }
    
    internal override func viewDidLoad() {
        super.viewDidLoad()
        configureTableView()
        configureMenu()
    }
    
    private func configureTableView() {
        let tableView: NSTableView = .init()
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
    
    @objc private func copyRoadAddr(_ sender: NSMenuItem) {
        guard let selectedString: String = selectedString else {
            return
        }
        NSPasteboard.general.declareTypes([.string], owner: nil)
        NSPasteboard.general.setString(selectedString, forType: .string)
    }
    
    @objc private func shareRoadAddr(_ sender: NSMenuItem) {
        guard let selectedString: String = selectedString,
              let selectedMenuRow: Int = selectedMenuRow,
              let cell: NSView = tableView?.rowView(atRow: selectedMenuRow, makeIfNecessary: false) else {
            return
        }
        
        let picker: NSSharingServicePicker = .init(items: [selectedString])
        picker.show(relativeTo: .zero, of: cell, preferredEdge: .minY)
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
        guard let clickedRow: Int = tableView?.clickedRow,
              clickedRow >= 0 else {
            return
        }
        
        guard dataSource.count > clickedRow else {
            return
        }
        
        let selectedString: String = dataSource[clickedRow].secondaryText
        self.selectedString = selectedString
        self.selectedMenuRow = clickedRow
        
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
