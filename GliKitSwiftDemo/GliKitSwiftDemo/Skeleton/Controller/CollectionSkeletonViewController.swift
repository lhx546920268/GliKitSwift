//
//  CollectionSkeletonViewController.swift
//  GliKitSwiftDemo
//
//  Created by 罗海雄 on 2020/10/21.
//  Copyright © 2020 luohaixiong. All rights reserved.
//

import GliKitSwift

class CollectionSkeletonViewController: CollectionViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor.gkGrayBackgroundColor
        registerClass(CollectionViewSkeletonCell.self)
        registerHeaderClass(CollectionViewSkeletonHeader.self)
        
        let size = (UIScreen.gkWidth - 10 * 4) / 3
        flowLayout.itemSize = CGSize(size, size)
        flowLayout.minimumLineSpacing = 10
        flowLayout.minimumInteritemSpacing = 10
        flowLayout.sectionInset = UIEdgeInsets.all(10)
        flowLayout.headerReferenceSize = CGSize(UIScreen.gkWidth, 50)
        
        initViews()
        
        collectionView.gkShowSkeleton(duration: 2) {
            self.collectionView.gkHideSkeleton(animate: true)
        }
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
