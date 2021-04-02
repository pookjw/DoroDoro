//
//  URLSchemesGuideViewController.swift
//  DoroDoro
//
//  Created by Jinwoo Kim on 4/2/21.
//

import UIKit

internal final class URLSchemesGuideViewController: UIViewController {
    private weak var collectionView: UICollectionView? = nil
    private var viewModel: URLSchemesGuideViewModel? = nil
    
    internal override func viewDidLoad() {
        super.viewDidLoad()
        setAttributes()
        configureCollectionView()
        configureViewModel()
    }
    
    private func setAttributes() {
        view.backgroundColor = .systemBackground
        title = "가이드(번역)"
    }
    
    private func configureCollectionView() {
        var layoutConfiguration: UICollectionLayoutListConfiguration = .init(appearance: .insetGrouped)
        layoutConfiguration.headerMode = .supplementary
        layoutConfiguration.footerMode = .supplementary
        let layout: UICollectionViewCompositionalLayout = .list(using: layoutConfiguration)
        
        let collectionView: UICollectionView = .init(frame: .zero, collectionViewLayout: layout)
        self.collectionView = collectionView
        view.addSubview(collectionView)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.snp.remakeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        collectionView.backgroundColor = .systemBackground
//        collectionView.delegate = self
    }
    
    private func configureViewModel() {
//        let viewModel: URLSchemesGuideViewModel = .init(dataSource: makeDataSource())
//        self.viewModel = viewModel
    }
}

extension URLSchemesGuideViewController: UICollectionViewDelegate {
    
}
