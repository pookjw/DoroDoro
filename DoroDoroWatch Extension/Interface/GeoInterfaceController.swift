//
//  GeoInterfaceController.swift
//  DoroDoro
//
//  Created by Jinwoo Kim on 3/7/21.
//

import WatchKit
import Combine

final internal class GeoInterfaceController: WKInterfaceController {
    @IBOutlet internal weak var findButton: WKInterfaceButton!
    @IBOutlet internal weak var loadingImageView: WKInterfaceImage!
    private var interfaceModel: GeoInterfaceModel? = nil
    private var cancellableBag: Set<AnyCancellable> = .init()
    
    override internal func awake(withContext context: Any?) {
        super.awake(withContext: context)
        setAttributes()
        configureInterfaceModel()
        bind()
    }
    
    @IBAction internal func startFinding() {
        startLoadingAnimation(in: loadingImageView) { [weak self] in
            self?.findButton.setHidden(true)
            self?.loadingImageView.setHidden(false)
        }
        interfaceModel?.requestGeoEvent()
    }
    
    private func setAttributes() {
        findButton.setHidden(false)
        loadingImageView.setHidden(true)
        setTitle(Localizable.LOCATION.string)
    }
    
    private func configureInterfaceModel() {
        interfaceModel = .init()
    }
    
    private func pushToDetails(roadAddr: String) {
        pushController(withName: "DetailsInterfaceController", context: ["roadAddr": roadAddr])
    }
    
    private func bind() {
        interfaceModel?.geoAPIService.coordErrorEvent
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] error in
                guard let self = self else { return }
                self.showErrorAlert(for: error)
                self.stopLoadingAnimation(in: self.loadingImageView) { [weak self] in
                    self?.findButton.setHidden(false)
                    self?.loadingImageView.setHidden(true)
                }
            })
            .store(in: &cancellableBag)
        
        interfaceModel?.kakaoAPIService.coord2AddressErrorEvent
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] error in
                guard let self = self else { return }
                self.showErrorAlert(for: error)
                self.stopLoadingAnimation(in: self.loadingImageView) { [weak self] in
                    self?.findButton.setHidden(false)
                    self?.loadingImageView.setHidden(true)
                }
            })
            .store(in: &cancellableBag)
        
        interfaceModel?.geoEvent
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] roadAddr in
                guard let self = self else { return }
                self.pushToDetails(roadAddr: roadAddr)
                self.stopLoadingAnimation(in: self.loadingImageView) { [weak self] in
                    self?.findButton.setHidden(false)
                    self?.loadingImageView.setHidden(true)
                }
            })
            .store(in: &cancellableBag)
    }
}
