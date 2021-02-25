//
//  SearchViewController.swift
//  DoroDoro
//
//  Created by Jinwoo Kim on 2/25/21.
//

import UIKit
import RxSwift
import RxCocoa

final class SearchViewController: UIViewController {
    private var disposeBag: DisposeBag = .init()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemTeal
        
//        APIService.shared.addrLinkEvent.subscribe(onNext: { print($0.common) })
//            .disposed(by: disposeBag)
//        APIService.shared.requestAddrLink(keyword: "성수동")
        
        APIService.shared.addrEngEvent.subscribe(onNext: { print($0.juso) }).disposed(by: disposeBag)
        APIService.shared.requestAddrEng(keyword: "성수동")
    }
}
