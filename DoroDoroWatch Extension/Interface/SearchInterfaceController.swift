//
//  SearchInterfaceController.swift
//  DoroDoroWatch Extension
//
//  Created by Jinwoo Kim on 2/25/21.
//

import WatchKit
import Combine
import DoroDoroWatchAPI

final internal class SearchInterfaceController: WKInterfaceController {
    @IBOutlet weak var topGroup: WKInterfaceGroup!
    @IBOutlet weak var tableGroup: WKInterfaceGroup!
    @IBOutlet weak var tableHeaderLabel: WKInterfaceLabel!
    @IBOutlet internal weak var tableView: WKInterfaceTable!
    @IBOutlet weak var loadingImageView: WKInterfaceImage!
    @IBOutlet weak var guideLabel: WKInterfaceLabel!
    
    private var interfaceModel: SearchInterfaceModel? = nil
    private var cancellableBag: Set<AnyCancellable> = .init()
    
    override internal func awake(withContext context: Any?) {
        super.awake(withContext: context)
        setAttributes()
        configureInterfaceModel()
        bind()
    }

    @IBAction internal func textFieldAction(_ value: NSString?) {
        startLoadingAnimation(in: loadingImageView) { [weak self] in
            self?.topGroup.setHidden(true)
            self?.tableGroup.setHidden(true)
            self?.guideLabel.setHidden(true)
            self?.loadingImageView.setHidden(false)
        }
        interfaceModel?.searchEvent = value as String?
    }
    
    private func setAttributes() {
        topGroup.setHidden(false)
        tableGroup.setHidden(true)
        loadingImageView.setHidden(true)
        guideLabel.setHidden(false)
        setTitle(Localizable.DORODORO.string)
    }
    
    private func configureInterfaceModel() {
        interfaceModel = .init()
    }
    
    private func bind() {
        interfaceModel?.linkJusoDataEvent
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] arrayData, text in
                guard let self = self else { return }
                self.startLoadingAnimation(in: self.loadingImageView) { [weak self] in
                    self?.topGroup.setHidden(false)
                    self?.tableGroup.setHidden(false)
                    self?.guideLabel.setHidden(false)
                    self?.loadingImageView.setHidden(true)
                }
                
                self.tableView.setNumberOfRows(arrayData.count, withRowType: "ResultCell")
                
                for (idx, data) in arrayData.enumerated() {
                    guard let object: SearchResultObject = self.tableView.rowController(at: idx) as? SearchResultObject else { return }
                    object.configure(data: data)
                }
                
                if arrayData.count == 0 {
                    self.tableGroup.setHidden(true)
                    self.guideLabel.setHidden(false)
                } else {
                    self.tableGroup.setHidden(false)
                    self.guideLabel.setHidden(true)
                }
                
                self.tableHeaderLabel.setText(text)
            })
            .store(in: &cancellableBag)
        
        interfaceModel?.addrAPIService.linkErrorEvent
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] error in
                guard let self = self else { return }
                self.startLoadingAnimation(in: self.loadingImageView) { [weak self] in
                    self?.topGroup.setHidden(false)
                    self?.tableGroup.setHidden(false)
                    self?.guideLabel.setHidden(false)
                    self?.loadingImageView.setHidden(true)
                }

                if self.interfaceModel?.linkJusoData.count == 0 || self.interfaceModel?.linkJusoData == nil {
                    self.tableGroup.setHidden(true)
                    self.guideLabel.setHidden(false)
                } else {
                    self.tableGroup.setHidden(false)
                    self.guideLabel.setHidden(true)
                }
                
                self.showErrorAlert(for: error)
            })
            .store(in: &cancellableBag)
    }
    
    private func pushToDetails(data: AddrLinkJusoData) {
//        pushController(withName: "DetailsInterfaceController", context: ["linkJusoData": data])
        pushController(withName: "DetailsInterfaceController", context: ["roadAddr": data.roadAddr])
    }
    
    override internal func table(_ table: WKInterfaceTable, didSelectRowAt rowIndex: Int) {
        super.table(table, didSelectRowAt: rowIndex)
        
        guard let viewModel: SearchInterfaceModel = interfaceModel else {
            return
        }
        guard viewModel.linkJusoData.count > rowIndex else {
            return
        }
        pushToDetails(data: viewModel.linkJusoData[rowIndex])
    }
}
