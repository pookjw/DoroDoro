//
//  SearchInterfaceController.swift
//  DoroDoroWatch Extension
//
//  Created by Jinwoo Kim on 2/25/21.
//

import WatchKit
import Combine

final internal class SearchInterfaceController: WKInterfaceController {
    @IBOutlet weak var topGroup: WKInterfaceGroup!
    @IBOutlet weak var tableGroup: WKInterfaceGroup!
    @IBOutlet weak var tableHeaderLabel: WKInterfaceLabel!
    @IBOutlet internal weak var tableView: WKInterfaceTable!
    @IBOutlet weak var loadingImage: WKInterfaceImage!
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
        startLoadingAnimating()
        interfaceModel?.searchEvent = value as String?
    }
    
    private func setAttributes() {
        topGroup.setHidden(false)
        tableGroup.setHidden(true)
        loadingImage.setHidden(true)
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
                self?.toggleStatus(isNormal: true)
                self?.tableView.setNumberOfRows(arrayData.count, withRowType: "ResultCell")
                
                for (idx, data) in arrayData.enumerated() {
                    guard let object: SearchResultObject = self?.tableView.rowController(at: idx) as? SearchResultObject else { return }
                    object.configure(data: data)
                }
                
                if arrayData.count == 0 {
                    self?.tableGroup.setHidden(true)
                    self?.guideLabel.setHidden(false)
                } else {
                    self?.tableGroup.setHidden(false)
                    self?.guideLabel.setHidden(true)
                }
                
                self?.tableHeaderLabel.setText(text)
            })
            .store(in: &cancellableBag)
        
        interfaceModel?.addrAPIService.linkErrorEvent
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] error in
                self?.toggleStatus(isNormal: true)

                if self?.interfaceModel?.linkJusoData.count == 0 || self?.interfaceModel?.linkJusoData == nil {
                    self?.tableGroup.setHidden(true)
                    self?.guideLabel.setHidden(false)
                } else {
                    self?.tableGroup.setHidden(false)
                    self?.guideLabel.setHidden(true)
                }
                
                self?.showErrorAlert(for: error)
            })
            .store(in: &cancellableBag)
    }
    
    private func toggleStatus(isNormal: Bool) {
        topGroup.setHidden(!isNormal)
        tableGroup.setHidden(!isNormal)
        loadingImage.setHidden(isNormal)
        
        if isNormal {
            stopLoadingAnimating()
        } else {
            startLoadingAnimating()
        }
    }
    
    private func startLoadingAnimating() {
        topGroup.setHidden(true)
        tableGroup.setHidden(true)
        guideLabel.setHidden(true)
        loadingImage.setHidden(false)
        loadingImage.setImageNamed("Animation")
        loadingImage.startAnimatingWithImages(in: NSRange(location: 0, length: 23), duration: 1, repeatCount: 0)
    }
    
    private func stopLoadingAnimating() {
        topGroup.setHidden(false)
        tableGroup.setHidden(false)
        guideLabel.setHidden(false)
        loadingImage.setHidden(true)
        loadingImage.stopAnimating()
        loadingImage.setImageNamed(nil)
    }
    
    override internal func table(_ table: WKInterfaceTable, didSelectRowAt rowIndex: Int) {
        super.table(table, didSelectRowAt: rowIndex)
        
        guard let viewModel: SearchInterfaceModel = interfaceModel else {
            return
        }
        guard viewModel.linkJusoData.count > rowIndex else {
            return
        }
        pushController(withName: "DetailsInterfaceController", context: ["linkJusoData": viewModel.linkJusoData[rowIndex]])
    }
}
