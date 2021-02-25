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
        
        APIService.shared.requestEvent
            .subscribe(onNext: { print($0) })
            .disposed(by: disposeBag)
        APIService.shared.request(keyword: "미아동")
    }
}
