//
//  DetailsViewController.swift
//  DoroDoro
//
//  Created by Jinwoo Kim on 3/1/21.
//

import UIKit

final internal class DetailsViewController: UIViewController {
    internal var item: SearchResultItem? = nil
    private weak var collectionView: UICollectionView? = nil
    
    override internal func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemPurple
    }
    
    deinit {
        printDeinitMessage()
    }
}
