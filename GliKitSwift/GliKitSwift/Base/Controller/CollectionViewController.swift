//
//  CollectionViewController.swift
//  GliKitSwift
//
//  Created by 罗海雄 on 2020/4/21.
//  Copyright © 2020 luohaixiong. All rights reserved.
//

import UIKit

///基础集合视图控制器
open class CollectionViewController: ScrollViewController, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {

    ///信息列表
    public private(set) lazy var collectionView: UICollectionView = {
        
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: self.layout)
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.alwaysBounceVertical = true
        collectionView.backgroundColor = .clear
        collectionView.backgroundView = nil
        
        collectionView.gkEmptyViewDelegate = self
        self.scrollView = collectionView
        
        return collectionView
    }()

    ///布局方式 default is 'UICollectionViewFlowLayout'
    public lazy var layout: UICollectionViewLayout = {
        
        return self.flowLayout
    }()

    ///默认流布局方式
    public private(set) lazy var flowLayout: UICollectionViewFlowLayout = {
        let layout = UICollectionViewFlowLayout()
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 0
        layout.scrollDirection = .vertical
        
        return layout
    }()
    
    open override func initViews() {
        super.initViews()
        contentView = collectionView
    }

    // MARK: - Register Cell
        
    ///注册cell
    public func registerNib(_ cls: AnyClass){
        collectionView.registerNib(cls)
    }
    
    public func registerClass(_ cls: AnyClass){
        collectionView.registerClass(cls)
    }

    public func registerHeaderClass(_ cls: AnyClass){
        collectionView.registerHeaderClass(cls)
    }
    
    public func registerHeaderNib(_ cls: AnyClass){
        collectionView.registerHeaderNib(cls)
    }

    public func registerFooterClass(_ cls: AnyClass){
        collectionView.registerFooterClass(cls)
    }
    
    public func registerFooterNib(_ cls: AnyClass){
        collectionView.registerFooterNib(cls)
    }

    // MARK: - UICollectionView delegate

    open func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 0
    }
    
    open func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        fatalError("\(self.gkNameOfClass) 必须实现 \(#function)")
    }

    open func collectionView(_ collectionView: UICollectionView, willDisplaySupplementaryView view: UICollectionReusableView, forElementKind elementKind: String, at indexPath: IndexPath) {
        //防止挡住滚动条
        if #available(iOS 11, *) {
            view.layer.zPosition = 0;
        }
    }
}
