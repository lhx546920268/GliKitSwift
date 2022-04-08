//
//  CollectionSkeletonViewController.swift
//  GliKitSwiftDemo
//
//  Created by 罗海雄 on 2020/10/21.
//  Copyright © 2020 luohaixiong. All rights reserved.
//

import GliKitSwift
import CoreGraphics

class CollectionSkeletonViewController: CollectionViewController {
    
    func oneDeWhy() {
//        super.viewDidLoad()
//
//        view.backgroundColor = UIColor.gkGrayBackgroundColor
//        registerClass(CollectionViewSkeletonCell.self)
//        registerHeaderClass(CollectionViewSkeletonHeader.self)
        
        let spacing: CGFloat = 10.0
        let count: CGFloat = 4.0
        let row: CGFloat = 3.0
        let used = spacing * count
        let width: CGFloat = UIScreen.gkWidth - used
        let size: CGFloat = width / row
        print(size)
//        flowLayout.itemSize = CGSize(size, size)
//        flowLayout.minimumLineSpacing = spacing
//        flowLayout.minimumInteritemSpacing = spacing
//        flowLayout.sectionInset = UIEdgeInsets.all(spacing)
//        flowLayout.headerReferenceSize = CGSize(UIScreen.gkWidth, 50)
        
//        initViews()
//
//        collectionView.gkShowSkeleton(duration: 2.0) {
//            self.collectionView.gkHideSkeleton(animate: true)
//        }
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 20
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        return collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: CollectionViewSkeletonHeader.gkNameOfClass, for: indexPath)
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        return collectionView.dequeueReusableCell(withReuseIdentifier: CollectionViewSkeletonCell.gkNameOfClass, for: indexPath)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
    }
}
